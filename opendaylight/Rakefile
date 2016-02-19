# Temporary fix for error caused by third party gems. See:
# https://github.com/maestrodev/puppet-blacksmith/issues/14
# https://github.com/dfarrell07/puppet-opendaylight/issues/6
require 'puppet/version'
require 'puppet/vendor/semantic/lib/semantic' unless Puppet.version.to_f <3.6

require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

# These two gems aren't always present, for instance
# on Travis with `--without local_only`
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

# NB: The centos:7.0.1406 and centos:7.1.1503 tags have fakesytemd, not
# the actually-functional systemd-container installed on centos:7
# https://github.com/CentOS/sig-cloud-instance-build/commit/3bf1e7bbf14deaa8c047c1dfbead6d0e8d0665f2
desc "Run Beaker tests against CentOS 7 Docker node."
task :centos_7_docker do
  sh "RS_SET=centos-7-docker INSTALL_METHOD=rpm bundle exec rake beaker"
end

desc "Run Beaker tests against Fedora 22 node."
task :fedora_22 do
  sh "RS_SET=fedora-22 INSTALL_METHOD=rpm bundle exec rake beaker"
end

desc "Run Beaker tests against Fedora 23 Docker node."
task :fedora_23_docker do
  sh "RS_SET=fedora-23-docker INSTALL_METHOD=rpm bundle exec rake beaker"
end

desc "Run Beaker tests against Ubuntu 14.04 node."
task :ubuntu_1404 do
  sh "RS_SET=ubuntu-1404 INSTALL_METHOD=tarball bundle exec rake beaker"
end

desc "Run Beaker tests against Ubuntu 14.04 Docker node."
task :ubuntu_1404_docker do
  sh "RS_SET=ubuntu-1404-docker INSTALL_METHOD=tarball bundle exec rake beaker"
end

# Note: Puppet currently doesn't support Ubuntu versions newer than 14.04
# https://docs.puppetlabs.com/guides/install_puppet/install_debian_ubuntu.html

desc "All tests, including Beaker tests against all nodes."
task :acceptance => [
  :test,
  :centos_7_docker,
]
