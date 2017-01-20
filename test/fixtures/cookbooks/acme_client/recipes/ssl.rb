#
# Author:: Thijs Houtenbos <thoutenbos@schubergphilis.com>
# Cookbook:: acme_client
# Recipe:: default
#
# Copyright 2015-2016 Schuberg Philis
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
acme_ssl_certificate '/etc/ssl/test.example.com.crt' do
  cn        'test.example.com'
  alt_names ['web.example.com', 'mail.example.com']
  output :fullchain

  key       '/etc/ssl/test.example.com.key'

  webserver :nginx

  notifies  :reload, 'service[nginx]'

  owner node[:nginx][:user]
end

acme_ssl_certificate '/etc/ssl/new.example.com.crt' do
  cn        'new.example.com'
  key       '/etc/ssl/new.example.com.key'

  webserver :nginx

  notifies :reload, 'service[nginx]'

  owner node[:nginx][:user]
end


