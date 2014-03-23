require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-syntax/tasks/puppet-syntax'
require 'puppet-lint/tasks/puppet-lint'

PuppetLint.configuration.fail_on_warnings
PuppetLint.configuration.send('disable_class_inherits_from_params_class')
task :default => [:spec, :lint, :syntax]
