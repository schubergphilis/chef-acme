#
# Author:: Thijs Houtenbos <thoutenbos@schubergphilis.com>
# Cookbook:: letsencrypt
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

source 'https://rubygems.org'

group :test do
  gem 'rake'
  gem 'berkshelf', '~> 4.0'
  gem 'solve', '= 2.0.2' # Bug: https://github.com/berkshelf/solve/issues/57
end

group :style do
  gem 'foodcritic', '~> 4.0.0'
  gem 'rubocop', '~> 0.34.0'
end

group :integration do
  gem 'test-kitchen', '~> 1.2'
end

group :integration_docker do
  gem 'kitchen-docker', '~> 2.1'
end

group :integration_vagrant do
  gem 'vagrant-wrapper', '~> 2.0'
  gem 'kitchen-vagrant', '~> 0.10'
end

group :integration_cloud do
  gem 'kitchen-ec2', '~> 0.8'
  gem 'kitchen-digitalocean', '~> 0.8'
  gem 'kitchen-sync'
end
