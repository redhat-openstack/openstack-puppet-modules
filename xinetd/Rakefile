require 'puppetlabs_spec_helper/rake_tasks'
begin
  require 'rspec-system/rake_task'
rescue LoadError
end

require 'puppet-lint/tasks/puppet-lint'
PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.relative = true
PuppetLint.configuration.ignore_paths = ["spec/**/*.pp", "pkg/**/*.pp"]
