#
# Author:: Thijs Houtenbos <thoutenbos@schubergphilis.com>
# Cookbook:: acme_server
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

package 'git'
package 'screen'

include_recipe 'yum'
include_recipe 'build-essential'
include_recipe 'sysctl::default'

chef_gem 'rest-client' do
  action :install
  compile_time false
end

# nginx package is broken
# https://www.centos.org/forums/viewtopic.php?f=47&t=55325
yum_repository 'CentOS-CR' do
  baseurl 'http://mirror.centos.org/centos/$releasever/cr/$basearch/'
  gpgkey 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'
  enabled true
  action :create
end

sysctl_param 'net.ipv6.conf.all.disable_ipv6' do
  value 1
end

sysctl_param 'net.ipv6.conf.default.disable_ipv6' do
  value 1
end

docker_service 'default' do
  action [:create, :start]
end

directory '/usr/local/src/boulder'

git '/usr/local/src/boulder' do
  repository 'https://github.com/letsencrypt/boulder'
  revision 'a2632fa155b52e7fb3cdbac122919f391cb7435b'
  action :checkout
end

cookbook_file '/usr/local/src/boulder/test/boulder-config.json' do
  source 'boulder-config.json'
end

ruby_block 'fix_dockerfile' do
  block do
    file = Chef::Util::FileEdit.new('/usr/local/src/boulder/Dockerfile')
    file.search_file_delete_line(/requirements.txt/)
    file.write_file
  end
end

ruby_block 'fix_fake_dns' do
  block do
    file = Chef::Util::FileEdit.new('/usr/local/src/boulder/test/dns-test-srv/main.go')
    file.search_file_replace(/"127.0.0.1"/, '"192.168.1.40"')
    file.write_file
  end
end

bash 'run_boulder' do
  code '/bin/screen -dmS boulder /usr/local/src/boulder/test/run-docker.sh'
  not_if '/bin/screen -list boulder | /bin/grep 1\ Socket\ in'
end

ruby_block 'wait_for_bootstrap' do
  block do
    require 'rest-client'
    times = 0
    loop do
      times += 1
      begin
        client = RestClient.get 'http://127.0.0.1:4000/directory'
      rescue
        sleep 10
      end
      break if times > 180 || (client && client.code == 200)
    end
  end
end
