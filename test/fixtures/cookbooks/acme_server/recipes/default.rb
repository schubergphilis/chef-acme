#
# Author:: Thijs Houtenbos <thoutenbos@schubergphilis.com>
# Cookbook:: acme_server
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

apt_update 'update' if platform_family?('debian')

include_recipe 'golang::default'

bash 'install pebble' do
  code <<-EOC
  source /etc/profile.d/golang.sh
  go get -u #{node['pebble']['package']}/...
  cd $GOPATH/src/#{node['pebble']['package']} && git checkout v1.0.1 && go install ./...
  EOC
  creates "#{node['go']['gopath']}/src/#{node['pebble']['package']}"
end

# Needed for the acme-client gem to continue connecting to pebble;
# please do NOT do this on production Chef nodes!
bash 'update Chef trusted certificates store' do
  code <<-EOC
  cat #{node['go']['gopath']}/src/#{node['pebble']['package']}/test/certs/pebble.minica.pem >> /opt/chef/embedded/ssl/certs/cacert.pem
  touch /opt/chef/embedded/ssl/certs/PEBBLE-MINICA-IS-INSTALLED
  EOC
  creates '/opt/chef/embedded/ssl/certs/PEBBLE-MINICA-IS-INSTALLED'
end

poise_service_user 'pebble'

# let pebble always validate and never reject requests
poise_service 'pebble' do
  command "#{node['go']['gobin']}/pebble -config ./test/config/pebble-config.json"
  user 'pebble'
  directory "#{node['go']['gopath']}/src/github.com/letsencrypt/pebble"
  environment(
    'GOPATH' => node['go']['gopath'],
    'GOBIN' => node['go']['gobin'],
    'PEBBLE_VA_ALWAYS_VALID' => 1,
    'PEBBLE_VA_NOSLEEP' => 1,
    'PEBBLE_WFE_NONCEREJECT' => 0
  )
end
