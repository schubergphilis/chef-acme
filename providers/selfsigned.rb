#
# Author:: Thijs Houtenbos <thoutenbos@schubergphilis.com>
# Cookbook:: letsencrypt
# Provider:: selfsigned
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
  file "#{new_resource.cn} SSL selfsigned key" do
    path      new_resource.key
    owner     new_resource.owner
    group     new_resource.group
    mode      00400
    content   OpenSSL::PKey::RSA.new(2048).to_pem
    sensitive true
    action    :create_if_missing
  end

  file "#{new_resource.cn} SSL selfsigned crt" do
    path    new_resource.crt
    owner   new_resource.owner
    group   new_resource.group
    mode    00644
    content lazy { self_signed_cert(new_resource.cn, OpenSSL::PKey::RSA.new(::File.read(new_resource.key))).to_pem }
    action  :create_if_missing
  end

  file "#{new_resource.cn} SSL selfsigned chain" do
    path    new_resource.chain
    owner   new_resource.owner
    group   new_resource.group
    mode    00644
    content lazy { self_signed_cert(new_resource.cn, OpenSSL::PKey::RSA.new(::File.read(new_resource.key))).to_pem }
    not_if  { new_resource.chain.nil? }
    action  :create_if_missing
  end
end
