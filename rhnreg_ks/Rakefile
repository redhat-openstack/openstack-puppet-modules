require 'rake'
require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'

require 'rspec/core/rake_task'
require 'puppet-lint/tasks/puppet-lint'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/*/*_spec.rb'
end
