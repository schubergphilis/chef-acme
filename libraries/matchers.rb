#
# Author:: Thijs Houtenbos <thoutenbos@schubergphilis.com>
# Cookbook:: acme
# Library:: matchers
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

if defined?(ChefSpec)
  ChefSpec.define_matcher(:acme_certificate)
  ChefSpec.define_matcher(:acme_selfsigned)

  def create_acme_selfsigned(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:acme_selfsigned, :create, resource_name)
  end

  def create_acme_certificate(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:acme_certificate, :create, resource_name)
  end
end
