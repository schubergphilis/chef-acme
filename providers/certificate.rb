#
# Author:: Thijs Houtenbos <thoutenbos@schubergphilis.com>
# Cookbook:: letsencrypt
# Provider:: certificate
#
# Copyright 2015 Schuberg Philis
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

use_inline_resources

action :create do
  unless new_resource.crt.nil? ^ new_resource.fullchain.nil?
    fail "[#{new_resource.cn}] No valid certificate output specified, only one of the crt/fullchain propery is permitted and required"
  end

  if new_resource.key.nil?
    fail "[#{new_resource.cn}] No valid key output specified, the key propery is required"
  end

  file "#{new_resource.cn} SSL key" do
    path      new_resource.key
    owner     new_resource.owner
    group     new_resource.group
    mode      00400
    content   OpenSSL::PKey::RSA.new(2048).to_pem
    sensitive true
    action    :nothing
  end.run_action(:create_if_missing)

  mycert   = nil
  mykey    = OpenSSL::PKey::RSA.new ::File.read new_resource.key
  renew_at = ::Time.now + 60 * 60 * 24 * node['letsencrypt']['renew']

  if !new_resource.crt.nil? && ::File.exist?(new_resource.crt)
    mycert   = ::OpenSSL::X509::Certificate.new ::File.read new_resource.crt
  elsif !new_resource.fullchain.nil? && ::File.exist?(new_resource.fullchain)
    mycert   = ::OpenSSL::X509::Certificate.new ::File.read new_resource.fullchain
  end

  if mycert.nil? || mycert.not_after <= renew_at
    all_validations = [new_resource.cn, new_resource.alt_names].flatten.compact.map do |domain|
      authz = acme_authz domain

      case authz.status
      when 'valid'
        case new_resource.method
        when 'http'
          authz.http01
        else
          fail "[#{new_resource.cn}] Invalid validation method '#{new_resource.method}'"
        end
      when 'pending'
        case new_resource.method
        when 'http'
          tokenpath = "#{new_resource.wwwroot}/#{authz.http01.filename}"

          tokenroot = directory ::File.dirname(tokenpath) do
            owner     new_resource.owner
            group     new_resource.group
            mode      00755
            recursive true
          end

          auth_file = file tokenpath do
            owner   new_resource.owner
            group   new_resource.group
            mode    00644
            content authz.http01.file_content
          end
          validation = acme_validate_immediately(authz, 'http01', tokenroot, auth_file)

          if validation.status != 'valid'
            fail "[#{new_resource.cn}] Validation failed for domain #{authz.domain}"
          end

          validation

        else
          fail "[#{new_resource.cn}] Invalid validation method '#{new_resource.method}'"
        end
      end
    end

    ruby_block "create certificate for #{new_resource.cn}" do
      block do
        if (all_validations.map { |authz| authz.status == 'valid' }).all?
          begin
            newcert = acme_cert(new_resource.cn, mykey, new_resource.alt_names)
          rescue Acme::Client::Error => e
            fail "[#{new_resource.cn}] Certificate request failed: #{e.message}"
          else
            Chef::Resource::File.new("#{new_resource.cn} SSL new crt", run_context).tap do |f|
              f.path    new_resource.crt || new_resource.fullchain
              f.owner   new_resource.owner
              f.group   new_resource.group
              f.content new_resource.crt.nil? ? newcert.fullchain_to_pem : newcert.to_pem
              f.mode    00644
            end.run_action :create

            Chef::Resource::File.new("#{new_resource.cn} SSL new chain", run_context).tap do |f|
              f.path    new_resource.chain
              f.owner   new_resource.owner
              f.group   new_resource.group
              f.content newcert.chain_to_pem
              f.not_if  { new_resource.chain.nil? }
              f.mode    00644
            end.run_action :create
          end
        else
          fail "[#{new_resource.cn}] Validation failed, unable to request certificate"
        end
      end
    end
  end
end
