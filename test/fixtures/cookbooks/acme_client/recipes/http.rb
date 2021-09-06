#
# Author:: Thijs Houtenbos <thoutenbos@schubergphilis.com>
# Cookbook:: acme_client
# Recipe:: default
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

include_recipe 'acme'

# Generate selfsigned certificate so nginx can start
acme_selfsigned 'test.example.com' do
  crt     '/etc/ssl/test.example.com.crt'
  key     '/etc/ssl/test.example.com.key'
end

include_recipe 'acme_client::nginx'

# Request the real certificate
acme_certificate 'test.example.com' do
  alt_names         ['test1.example.com', 'test2.example.com']
  crt               '/etc/ssl/test.example.com.crt'
  key               '/etc/ssl/test.example.com.key'
  wwwroot           '/var/www/html'
  notifies          :reload, 'nginx_service[nginx]', :immediately
end

acme_certificate 'new.example.com' do
  crt               '/etc/ssl/new.example.com.crt'
  key               '/etc/ssl/new.example.com.key'
  wwwroot           '/var/www/html'
end

acme_certificate '4096.example.com' do
  crt               '/etc/ssl/4096.example.com.crt'
  key               '/etc/ssl/4096.example.com.key'
  key_size          4096
  wwwroot           '/var/www/html'
end

acme_certificate 'web.example.com' do
  alt_names         ['mail.example.com']
  crt               '/etc/ssl/web.example.com.crt'
  key               '/etc/ssl/web.example.com.key'
  wwwroot           '/var/www/html'
  notifies          :reload, 'nginx_service[nginx]', :immediately
end
