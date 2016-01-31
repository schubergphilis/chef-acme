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

desc 'Run Test Kitchen integration tests'
namespace :integration do
  # Gets a collection of instances.
  #
  # @param regexp [String] regular expression to match against instance names.
  # @param config [Hash] configuration values for the `Kitchen::Config` class.
  # @return [Collection<Instance>] all instances.
  def kitchen_instances(regexp, config)
    instances = Kitchen::Config.new(config).instances
    return instances if regexp.nil? || regexp == 'all'
    instances.get_all(Regexp.new(regexp))
  end

  # Runs a test kitchen action against some instances.
  #
  # @param action [String] kitchen action to run (defaults to `'test'`).
  # @param regexp [String] regular expression to match against instance names.
  # @param loader_config [Hash] loader configuration options.
  # @return void
  def run_kitchen(action, regexp, loader_config = {})
    action = 'test' if action.nil?
    require 'kitchen'
    Kitchen.logger = Kitchen.default_file_logger
    config = { loader: Kitchen::Loader::YAML.new(loader_config) }
    kitchen_instances(regexp, config).each { |i| i.send(action) }
  end

  desc 'Run Test Kitchen integration tests using vagrant'
  task :vagrant, [:regexp, :action] do |_t, args|
    run_kitchen(args.action, args.regexp)
  end

  desc 'Run Test Kitchen integration tests using docker'
  task :docker, [:regexp, :action] do |_t, args|
    run_kitchen(args.action, args.regexp, local_config: '.kitchen.docker.yml')
  end

  desc 'Run Test Kitchen integration tests in the cloud'
  task :cloud, [:regexp, :action] do |_t, args|
    run_kitchen(args.action, args.regexp, local_config: '.kitchen.cloud.yml')
  end
end

desc 'Run Test Kitchen integration tests'
task :integration, [:regexp, :action] =>
  ci? ? %w(integration:docker) : %w(integration:vagrant)

desc 'Run style and integration tests'
task default: %w(style integration)
