#
# Author:: Thijs Houtenbos <thoutenbos@schubergphilis.com>
# Cookbook:: letsencrypt
# Attribute:: default
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

default['letsencrypt']['contact']     = []
default['letsencrypt']['endpoint']    = 'https://acme-v01.api.letsencrypt.org'
default['letsencrypt']['renew']       = 30
default['letsencrypt']['source_ips']  = ['66.133.109.36']

default['letsencrypt']['private_key'] = nil

