#
# Author:: Thijs Houtenbos <thoutenbos@schubergphilis.com>
# Cookbook:: acme
# Resource:: ssl_key
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

default_action :create_if_missing

property :path,          String, :name_attribute => true
property :length,        Integer,                                  :default => 2048
property :output_format, Symbol, :equal_to => [:pem, :der, :text], :default => :pem
property :type,          Symbol, :equal_to => [:rsa, :dsa],        :default => :rsa

def load
  klass = OpenSSL::PKey.const_get(type.upcase)
  klass.new(::File.read(path)) if ::File.exist?(path)
end

def do_action(file_action)
  klass = OpenSSL::PKey.const_get(new_resource.type.upcase)
  key = klass.new(new_resource.length)
  data = key.send("to_#{new_resource.output_format}".to_sym)

  file new_resource.path do
    owner     owner
    group     group
    mode      00400
    content   data
    sensitive true

    action file_action
  end
end

action :create do
  do_action(:create)
end

action :destroy do
  do_action(:destroy)
end

action :create_if_missing do
  do_action(:create_if_missing)
end
