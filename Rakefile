#
# Author:: Thijs Houtenbos <thoutenbos@schubergphilis.com>
# Cookbook:: acme
#
# Copyright 2015-2017 Schuberg Philis
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

require 'bundler/setup'

# Checks if we are inside a Continuous Integration machine.
#
# @return [Boolean] whether we are inside a CI.
# @example
#   ci? #=> false
def ci?
  ENV['CI'] == 'true'
end

namespace :style do
  require 'rubocop/rake_task'
  desc 'Run Ruby style checks using rubocop'
  RuboCop::RakeTask.new(:ruby)

  require 'foodcritic'
  desc 'Run Chef style checks using foodcritic'
  FoodCritic::Rake::LintTask.new(:chef)
end

desc 'Run all style checks'
task :style => ['style:chef', 'style:ruby']

# Integration tests. Kitchen.ci
namespace :integration do
  begin
    require 'kitchen/rake_tasks'

    desc 'Run kitchen integration tests'
    Kitchen::RakeTasks.new(:integratio)
  rescue StandardError => e
    puts ">>> Kitchen error: #{e}, omitting #{task.name}" unless ENV['CI']
  end
end

desc 'Run all integration checks'
task :integration => ['integration:kitchen:all']

desc 'Run style and integration tests'
task default: %w(style integration)
