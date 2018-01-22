#
# Author:: Thijs Houtenbos <thoutenbos@schubergphilis.com>
# Cookbook:: acme
# Resource:: certificate
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

actions :create
default_action :create

attribute :cn,                  :kind_of => String, :required => true
attribute :alt_names,           :kind_of => Array,  :default => []

attribute :path,                :kind_of => String, :name_attribute => true
attribute :output,				:kind_of => Symbol, :equal_to => [:crt, :fullchain], :default => :crt

attribute :key,                 :kind_of => String, :required => true

attribute :owner,               :kind_of => String
attribute :group,               :kind_of => String

attribute :min_validity,        :kind_of => Integer

attribute :validation_method,   :kind_of => Symbol, :default => :tls_sni01

attribute :endpoint, :kind_of => String, :default => nil
attribute :contact, :kind_of => Array, :default => []

def webserver(server)
	sym = server.to_sym.capitalize

	raise "Unknown server: #{sym}. Available: #{Chef::Provider::SSLCertificate.constants}" unless Chef::Provider::SSLCertificate.const_defined?(sym)
	provider(Chef::Provider::SSLCertificate.const_get(sym))
end

def min_expiry
	Time.now + 3600 * 24 * (@min_validity || node[:acme][:renew])
end

def after_created
end
