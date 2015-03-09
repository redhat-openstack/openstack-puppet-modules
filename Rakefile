# Temporary fix for error caused by third party gems. See:
# https://github.com/maestrodev/puppet-blacksmith/issues/14
# https://github.com/dfarrell07/puppet-opendaylight/issues/6
require 'puppet/version'
require 'puppet/vendor/semantic/lib/semantic' unless Puppet.version.to_f <3.6

require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

# These two gems aren't always present, for instance
# on Travis with --without development
begin
  require 'puppet_blacksmith/rake_tasks'
rescue LoadError
end

PuppetLint.configuration.relative = true
PuppetLint.configuration.send("disable_80chars")
PuppetLint.configuration.log_format = "%{path}:%{linenumber}:%{check}:%{KIND}:%{message}"
PuppetLint.configuration.fail_on_warnings = true

# Forsake support for Puppet 2.6.2 for the benefit of cleaner code.
# http://puppet-lint.com/checks/class_parameter_defaults/
PuppetLint.configuration.send('disable_class_parameter_defaults')
# http://puppet-lint.com/checks/class_inherits_from_params_class/
PuppetLint.configuration.send('disable_class_inherits_from_params_class')

exclude_paths = [
  "bundle/**/*",
  "pkg/**/*",
  "vendor/**/*",
  "spec/**/*",
]
PuppetLint.configuration.ignore_paths = exclude_paths
PuppetSyntax.exclude_paths = exclude_paths

task :metadata do
  sh "metadata-json-lint metadata.json"
end

desc "Run syntax, lint, and spec tests."
task :test => [
  :syntax,
  :lint,
  :spec,
  :metadata,
]

desc "Run Beaker tests against CentOS 7 node."
task :centos do
  sh "RS_SET=centos-7 INSTALL_METHOD=rpm bundle exec rake beaker"
end

desc "Run Beaker tests against CentOS 7 using tarball install."
task :centos_tarball do
  sh "RS_SET=centos-7 INSTALL_METHOD=tarball bundle exec rake beaker"
end

desc "Run Beaker tests against Fedora 20 node."
task :fedora_20 do
  sh "RS_SET=fedora-20 bundle exec rake beaker"
end

desc "Run Beaker tests against Fedora 21 node."
task :fedora_21 do
  sh "RS_SET=fedora-21 bundle exec rake beaker"
end

desc "All tests, including Beaker tests against all nodes."
task :acceptance => [
  :test,
  :centos,
  :fedora_20,
  :fedora_21,
]
