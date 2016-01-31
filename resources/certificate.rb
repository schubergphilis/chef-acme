#
# Author:: Thijs Houtenbos <thoutenbos@schubergphilis.com>
# Cookbook:: letsencrypt
# Resource:: certificate
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

actions :create
default_action :create

attribute :cn,            :kind_of => String, :name_attribute => true
attribute :alt_names,     :kind_of => Array,  :default => []

attribute :crt,           :kind_of => String, :default => nil
attribute :key,           :kind_of => String, :default => nil

attribute :chain,         :kind_of => String, :default => nil
attribute :fullchain,     :kind_of => String, :default => nil

attribute :owner,         :kind_of => String, :default => 'root'
attribute :group,         :kind_of => String, :default => 'root'

attribute :method,        :kind_of => String, :default => 'http'
attribute :wwwroot,       :kind_of => String, :default => '/var/www'
