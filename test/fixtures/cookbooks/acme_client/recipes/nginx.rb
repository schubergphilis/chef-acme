#
# Author:: Thijs Houtenbos <thoutenbos@schubergphilis.com>
# Cookbook:: acme_client
# Recipe:: nginx
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

# Install a webserver
include_recipe 'nginx'

cookbook_file "#{node['nginx']['dir']}/sites-available/test" do
  source 'nginx-test.conf'
end

directory node['nginx']['default_root'] do
  owner 'root'
  group 'root'
  recursive true
end

cookbook_file "#{node['nginx']['default_root']}/index.html" do
  source 'index.html'
end

nginx_site 'test' do
  timing :immediately
end
