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
package 'libtool-ltdl-devel'
package 'initscripts'
package 'logrotate'
package 'tar'
package 'wget'

yum_repository 'mariadb-10.0' do
  baseurl 'https://downloads.mariadb.com/files/MariaDB/yum/10.0/centos/7/x86_64'
  gpgkey 'https://yum.mariadb.org/RPM-GPG-KEY-MariaDB'
  enabled true
  action :create
end

include_recipe 'build-essential'
include_recipe 'mariadb::server'
include_recipe 'rabbitmq'
include_recipe 'golang'

chef_gem 'rest-client' do
  action :install
  compile_time false
end

# https://github.com/letsencrypt/boulder/pull/1071
bash 'set_hosts' do
  code '/bin/echo 127.0.0.1 localhost > /etc/hosts'
end

boulderdir = "#{node['go']['gopath']}/src/github.com/letsencrypt/boulder"

directory ::File.dirname boulderdir do
  recursive true
end

git boulderdir do
  repository 'https://github.com/letsencrypt/boulder'
  revision '8e6f13f189d7e7feb0f5407a9a9c63f3b644f730'
  action :checkout
end

ruby_block 'boulder_config' do
  block do
    config = ::JSON.parse ::File.read "#{boulderdir}/test/boulder-config.json"
    config['va']['portConfig']['httpPort'] = 80
    config['va']['portConfig']['httpsPort'] = 443
    config['va']['portConfig']['tlsPort'] = 443
    config['syslog']['network'] = 'udp'
    config['syslog']['server'] = 'localhost:514'
    ::File.write("#{boulderdir}/test/boulder-config.json", ::JSON.pretty_generate(config))

    config = ::JSON.parse ::File.read "#{boulderdir}/test/issuer-ocsp-responder.json"
    config['syslog'] = {}
    config['syslog']['network'] = 'udp'
    config['syslog']['server'] = 'localhost:514'
    ::File.write("#{boulderdir}/test/issuer-ocsp-responder.json", ::JSON.pretty_generate(config))
  end
end

ruby_block 'boulder_limit' do
  block do
    limit = ::YAML.load ::File.read "#{boulderdir}/test/rate-limit-policies.yml"
    limit['certificatesPerName']['threshold'] = 999
    ::File.write("#{boulderdir}/test/rate-limit-policies.yml", limit.to_yaml)
  end
end

execute 'boulder_setup' do
  cwd boulderdir
  command 'source /etc/profile.d/golang.sh && ./test/setup.sh 2>&1 && touch setup.done'
  creates "#{boulderdir}/setup.done"
end

bash 'run_boulder' do
  cwd boulderdir
  code 'source /etc/profile.d/golang.sh && /bin/screen -LdmS boulder ./start.py'
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
        puts ::File.read "#{boulderdir}/screenlog.0"
      end
      Chef::Application.fatal!('Failed to run boulder server') if times > 30
      break if client && client.code == 200
    end
  end
end
