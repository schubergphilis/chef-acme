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
    Chef::Log.error("[#{new_resource.cn}] No valid certificate output specified, only one of the crt/fullchain propery is permitted and required")
    return
  end

  if new_resource.key.nil?
    Chef::Log.error("[#{new_resource.cn}] No valid key output specified, the key propery is required")
    return
  end

  file "#{new_resource.cn} SSL key" do
    path      new_resource.key
    owner     new_resource.owner
    group     new_resource.group
    mode      00400
    content   OpenSSL::PKey::RSA.new(2048).to_pem
    sensitive true
    action    :create_if_missing
  end

  mycert   = nil
  mykey    = OpenSSL::PKey::RSA.new ::File.read new_resource.key
  renew_at = ::Time.now + 60 * 60 * 24 * node['letsencrypt']['renew']

  if !new_resource.crt.nil? && ::File.exist?(new_resource.crt)
    mycert   = ::OpenSSL::X509::Certificate.new ::File.read new_resource.crt
  elsif !new_resource.fullchain.nil? && ::File.exist?(new_resource.fullchain)
    mycert   = ::OpenSSL::X509::Certificate.new ::File.read new_resource.fullchain
  end

  if mycert.nil? || mycert.not_after <= renew_at
    authz = acme_authz new_resource.cn

    case authz.status
    when 'valid'
      newcert = acme_cert(new_resource.cn, mykey)

      file "#{new_resource.cn} SSL new crt" do
        path    new_resource.crt || new_resource.fullchain
        owner   new_resource.owner
        group   new_resource.group
        content new_resource.crt.nil? ? newcert.fullchain_to_pem : newcert.to_pem
        mode    00644
        action  :create
      end

      file "#{new_resource.cn} SSL new chain" do
        path    new_resource.chain
        owner   new_resource.owner
        group   new_resource.group
        content newcert.chain_to_pem
        not_if  { new_resource.chain.nil? }
        mode    00644
        action  :create
      end

    when 'pending'
      case new_resource.method
      when 'http'
        tokenpath = "#{new_resource.wwwroot}/#{authz.http01.filename}"

        directory ::File.dirname(tokenpath) do
          owner     new_resource.owner
          group     new_resource.group
          mode      00755
          recursive true
        end

        file tokenpath do
          owner   new_resource.owner
          group   new_resource.group
          mode    00644
          content authz.http01.file_content
        end

        validate = authz.http01

      else
        Chef::Log.error("[#{new_resource.cn}] Invalid validation method '#{new_resource.method}'")
      end

      ruby_block "validate domain #{new_resource.cn}" do
        block do
          validation = acme_validate validate

          case validation.verify_status
          when 'valid'
            begin
              newcert = acme_cert(new_resource.cn, mykey)
            rescue Acme::Error => e
              Chef::Log.error("[#{new_resource.cn}] Certificate request failed: #{e.message}")
            else
              file "#{new_resource.cn} SSL new crt" do
                path    new_resource.crt || new_resource.fullchain
                owner   new_resource.owner
                group   new_resource.group
                content new_resource.crt.nil? ? newcert.fullchain_to_pem : newcert.to_pem
                mode    00644
                action  :create
              end

              file "#{new_resource.cn} SSL new chain" do
                path    new_resource.chain
                owner   new_resource.owner
                group   new_resource.group
                content newcert.chain_to_pem
                not_if  { new_resource.chain.nil? }
                mode    00644
                action  :create
              end
            end
          else
            Chef::Log.error("[#{new_resource.cn}] Domain validation failed")
          end
        end
      end
    end
  end
end
