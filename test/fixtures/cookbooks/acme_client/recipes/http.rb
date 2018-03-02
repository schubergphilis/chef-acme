#
# Author:: Thijs Houtenbos <thoutenbos@schubergphilis.com>
# Cookbook:: acme_client
# Recipe:: default
#
# Copyright 2015-2018 Schuberg Philis
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

include_recipe 'acme'

# Generate selfsigned certificate so nginx can start
acme_selfsigned 'test.example.com' do
  crt     '/etc/ssl/test.example.com.crt'
  key     '/etc/ssl/test.example.com.key'
end

include_recipe 'acme_client::nginx'

# Request the real certificate
acme_certificate 'test.example.com' do
  alt_names         ['web.example.com', 'mail.example.com']
  fullchain         '/etc/ssl/test.example.com.crt'
  chain             '/etc/ssl/test.example.com-chain.crt'
  key               '/etc/ssl/test.example.com.key'
  wwwroot           node['nginx']['default_root']
  notifies          :reload, 'service[nginx]'
end

acme_certificate 'new.example.com' do
  crt               '/etc/ssl/new.example.com.crt'
  chain             '/etc/ssl/new.example.com-chain.crt'
  key               '/etc/ssl/new.example.com.key'
  wwwroot           node['nginx']['default_root']
end

acme_certificate '4096.example.com' do
  crt               '/etc/ssl/4096.example.com.crt'
  chain             '/etc/ssl/4096.example.com-chain.crt'
  key               '/etc/ssl/4096.example.com.key'
  key_size          4096
  wwwroot           node['nginx']['default_root']
end

acme_certificate 'web.example.com' do
  fullchain         '/etc/ssl/web.example.com.crt'
  chain             '/etc/ssl/web.example.com-chain.crt'
  key               '/etc/ssl/web.example.com.key'
  wwwroot           node['nginx']['default_root']
  notifies          :reload, 'service[nginx]'
end

acme_certificate 'web.example.com' do
  alt_names         ['mail.example.com']
  fullchain         '/etc/ssl/web.example.com.crt'
  chain             '/etc/ssl/web.example.com-chain.crt'
  key               '/etc/ssl/web.example.com.key'
  wwwroot           node['nginx']['default_root']
  notifies          :reload, 'service[nginx]'
end
