#
# Author:: Thijs Houtenbos <thoutenbos@schubergphilis.com>
# Cookbook:: letsencrypt
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

chef_gem 'activesupport' do
  action :install
  version '4.2.6'
  compile_time true if respond_to?(:compile_time)
  only_if { node['letsencrypt']['gem_deps'] }
end

chef_gem 'json-jwt' do
  action :install
  version '1.5.2'
  compile_time true if respond_to?(:compile_time)
  only_if { node['letsencrypt']['gem_deps'] }
end

chef_gem 'acme-client' do
  action :install
  version '0.3.6'
  compile_time true if respond_to?(:compile_time)
end

require 'acme-client'
