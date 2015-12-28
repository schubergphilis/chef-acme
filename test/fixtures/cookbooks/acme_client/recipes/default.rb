#
# Author:: Thijs Houtenbos <thoutenbos@schubergphilis.com>
# Cookbook:: acme_client
# Recipe:: default
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

include_recipe 'yum'
include_recipe 'letsencrypt'

# nginx package is broken
# https://www.centos.org/forums/viewtopic.php?f=47&t=55325
yum_repository 'CentOS-CR' do
  baseurl 'http://mirror.centos.org/centos/$releasever/cr/$basearch/'
  gpgkey 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'
  enabled true
  action :create
end

# Generate selfsigned certificate so nginx can start
letsencrypt_selfsigned 'test.example.com' do
  crt     '/etc/ssl/test.example.com.crt'
  key     '/etc/ssl/test.example.com.key'
end

include_recipe 'acme_client::nginx'

# Request the real certificate
letsencrypt_certificate 'test.example.com' do
  alt_names ['web.example.com', 'mail.example.com']
  fullchain '/etc/ssl/test.example.com.crt'
  chain     '/etc/ssl/test.example.com-chain.crt'
  key       '/etc/ssl/test.example.com.key'
  method    'http'
  wwwroot   node['nginx']['default_root']
  notifies  :reload, 'service[nginx]'
end
