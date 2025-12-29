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

hostsfile_entry '127.0.0.1' do
  hostname 'localhost'
  aliases [
    'localhost.localdomain',
    'localhost4',
    'localhost4.localdomain4',
    'test.example.com',
    'test1.example.com',
    'test2.example.com',
    'new.example.com',
    'web.example.com',
    'mail.example.com',
    '4096.example.com',
    'ec.example.com',
    'short.example.com',
]
end

# Generate selfsigned certificates so nginx can start
%w(test new web ec).each do |n|
  acme_selfsigned "#{n}.example.com" do
    crt     "/etc/ssl/#{n}.example.com.crt"
    key     "/etc/ssl/#{n}.example.com.key"
  end
end

include_recipe 'acme_client::nginx'

# Request the real certificate
acme_certificate 'test.example.com' do
  alt_names         ['test1.example.com', 'test2.example.com']
  crt               '/etc/ssl/test.example.com.crt'
  key               '/etc/ssl/test.example.com.key'
  wwwroot           '/var/www/html'
  profile           'tlsserver'
  notifies          :reload, 'nginx_service[nginx]', :immediately
end

acme_certificate 'new.example.com' do
  crt               '/etc/ssl/new.example.com.crt'
  key               '/etc/ssl/new.example.com.key'
  wwwroot           '/var/www/html'
  profile           'tlsserver'
end

acme_certificate '4096.example.com' do
  crt               '/etc/ssl/4096.example.com.crt'
  key               '/etc/ssl/4096.example.com.key'
  key_size          4096
  wwwroot           '/var/www/html'
  profile           'tlsserver'
end

acme_certificate 'web.example.com' do
  alt_names         ['mail.example.com']
  crt               '/etc/ssl/web.example.com.crt'
  key               '/etc/ssl/web.example.com.key'
  wwwroot           '/var/www/html'
  profile           'tlsserver'
  notifies          :reload, 'nginx_service[nginx]', :immediately
end

# Generate selfsigned certificate with both DNS and IP SANs for test
acme_selfsigned 'ip.example.com' do
  alt_names         ['192.168.18.17']
  crt               '/etc/ssl/ip.example.com.crt'
  key               '/etc/ssl/ip.example.com.key'
end

acme_certificate 'ec.example.com' do
  crt               '/etc/ssl/ec.example.com.crt'
  key               '/etc/ssl/ec.example.com.key'
  key_type          'ec'
  ec_curve          'prime256v1'
  wwwroot           '/var/www/html'
  profile           'tlsserver'
end

# Request certificate with both DNS and IP SANs (requires short-lived profile)
acme_certificate 'short.example.com' do
  alt_names         [node['ipaddress']]
  crt               '/etc/ssl/short.example.com.crt'
  key               '/etc/ssl/short.example.com.key'
  wwwroot           '/var/www/html'
  profile           'shortlived'
  notifies          :reload, 'nginx_service[nginx]', :immediately
end
