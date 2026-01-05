#
# Author:: Thijs Houtenbos <thoutenbos@schubergphilis.com>
# Cookbook:: acme
# Resource:: selfsigned
#
# Copyright:: 2015-2021, Schuberg Philis
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

unified_mode true

default_action :create

property :cn,         String, name_property: true
property :alt_names,  Array,  default: []

property :crt,        [String, nil], required: true
property :key,        [String, nil], required: true

property :chain,      [String, nil]

property :owner,      [String, Integer], default: 'root'
property :group,      [String, Integer], default: 'root'

property :key_size,   Integer, default: lazy { node['acme']['key_size'] }, equal_to: [2048, 3072, 4096]
property :key_type,   String, default: 'rsa', equal_to: %w(rsa ec)
property :ec_curve,   String, default: lazy { node['acme']['ec_curve'] }, equal_to: %w(prime256v1 secp384r1 secp521r1)

action :create do
  file "#{new_resource.cn} SSL selfsigned key" do
    path      new_resource.key
    owner     new_resource.owner
    group     new_resource.group
    mode      '400'
    content   case new_resource.key_type
              when 'rsa'
                OpenSSL::PKey::RSA.new(new_resource.key_size).to_pem
              when 'ec'
                OpenSSL::PKey::EC.generate(new_resource.ec_curve).to_pem
              end
    sensitive true
    action    :create_if_missing
  end

  file "#{new_resource.cn} SSL selfsigned crt" do
    path    new_resource.crt
    owner   new_resource.owner
    group   new_resource.group
    mode    '644'
    content lazy { self_signed_cert(new_resource.cn, new_resource.alt_names, OpenSSL::PKey.read(::File.read(new_resource.key))).to_pem }
    action  :create_if_missing
  end

  file "#{new_resource.cn} SSL selfsigned chain" do
    path    new_resource.chain unless new_resource.chain.nil?
    owner   new_resource.owner
    group   new_resource.group
    mode    '644'
    content lazy { self_signed_cert(new_resource.cn, new_resource.alt_names, OpenSSL::PKey.read(::File.read(new_resource.key))).to_pem }
    not_if  { new_resource.chain.nil? }
    action  :create_if_missing
  end
end
