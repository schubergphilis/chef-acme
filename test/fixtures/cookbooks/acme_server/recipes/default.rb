#
# Author:: Thijs Houtenbos <thoutenbos@schubergphilis.com>
# Cookbook:: acme_server
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

apt_update 'update' if platform_family?('debian')
package 'selinux-utils' if platform_family?('debian')

node.default['golang']['version'] = '1.24.4'

platform = case node['kernel']['machine']
  when /i.86/
    '386'
  when /aarch64/
    'arm64'
  else
    'amd64'
  end

golang 'Install go' do
  scm_packages ['git']
  version node['golang']['version'] if node['golang']['version']
  url "https://go.dev/dl/go#{node['golang']['version']}.linux-#{platform}.tar.gz"
end

node['golang']['packages'].each do |package|
  golang_package package
end

git '/usr/local/src/pebble' do
  repository 'https://github.com/letsencrypt/pebble.git'
  revision 'v2.8.0'
end

execute '/usr/local/go/bin/go install ./cmd/pebble' do
  cwd '/usr/local/src/pebble'
  environment ({'GOPATH' => '/opt/go', 'GOBIN' => '/opt/go/bin'})
end

selinux_fcontext '/opt/go/bin/pebble' do
  secontext 'usr_t'
end

cookbook_file '/usr/local/src/pebble/test/config/pebble-config.json' do
  source 'pebble-config.json'
end

# Needed for the acme-client gem to continue connecting to pebble;
# please do NOT do this on production Chef nodes!
execute 'update Chef trusted certificates store' do
  command "cat /usr/local/src/pebble/test/certs/pebble.minica.pem >> /opt/chef/embedded/ssl/certs/cacert.pem && touch /opt/chef/embedded/ssl/certs/PEBBLE-MINICA-IS-INSTALLED"
  creates '/opt/chef/embedded/ssl/certs/PEBBLE-MINICA-IS-INSTALLED'
end

user 'pebble' do
  system true
  shell '/bin/false'
end

systemd_unit 'pebble.service' do
  content <<~EOU
    [Unit]
    Description=Pebble ACME Server

    [Service]
    User=pebble
    WorkingDirectory=/usr/local/src/pebble
    ExecStart=#{node['golang']['gobin']}/pebble -config ./test/config/pebble-config.json
    Environment="GOPATH=#{node['golang']['gopath']}"
    Environment="GOBIN=#{node['golang']['gobin']}"
    Environment="PEBBLE_VA_ALWAYS_VALID=0"
    Environment="PEBBLE_VA_NOSLEEP=1"
    Environment="PEBBLE_WFE_NONCEREJECT=0"
    Environment="PEBBLE_AUTHZREUSE=0"

    [Install]
    WantedBy=multi-user.target
  EOU
  action :create
end

service 'pebble' do
  action [:enable, :start]
end
