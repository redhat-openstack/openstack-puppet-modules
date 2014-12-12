require 'rake/clean'

CLEAN.include('spec/fixtures/manifests/', 'spec/fixtures/modules/', 'doc', 'pkg')
CLOBBER.include('.tmp', '.librarian')

require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet_blacksmith/rake_tasks'

require 'puppet-lint/tasks/puppet-lint'
PuppetLint.configuration.send("disable_80chars")
PuppetLint.configuration.fail_on_warnings = true
PuppetLint.configuration.relative = true

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:beaker) do |c|
  c.pattern = "spec/acceptance/**/*_spec.rb"
end

task :default => [:clean, :lint, :spec]
