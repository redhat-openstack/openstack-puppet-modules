# Author::    Liam Bennett  (mailto:lbennett@opentable.com)
# Copyright:: Copyright (c) 2013 OpenTable Inc
# License::   MIT

# == Class: kafka::consumer
#
# This class will install kafka with the consumer role.
#
# === Requirements/Dependencies
#
# Currently requires the puppetlabs/stdlib module on the Puppet Forge in
# order to validate much of the the provided configuration.
#
# === Parameters
#
# [*version*]
# The version of kafka that should be installed.
#
# [*scala_version*]
# The scala version what kafka was built with.
#
# [*install_dir*]
# The directory to install kafka to.
#
# [*mirror_url*]
# The url where the kafka is downloaded from.
#
# [*config*]
# A hash of the consumer configuration options.
#
# [*install_java*]
# Install java if it's not already installed.
#
# [*package_dir*]
# The directory to install kafka.
#
# [*service_restart*]
# Boolean, if the configuration files should trigger a service restart
#
# === Examples
#
# Create the consumer service connecting to a local zookeeper
#
# class { 'kafka::consumer':
#  config => { 'client.id' => '0', 'zookeeper.connect' => 'localhost:2181' }
# }
class kafka::consumer (
  $version = $kafka::params::version,
  $scala_version = $kafka::params::scala_version,
  $install_dir = $kafka::params::install_dir,
  $mirror_url = $kafka::params::mirror_url,
  $config = $kafka::params::consumer_config_defaults,
  $install_java = $kafka::params::install_java,
  $package_dir = $kafka::params::package_dir,
  $service_restart = $kafka::params::service_restart
) inherits kafka::params {

  validate_re($::osfamily, 'RedHat|Debian\b', "${::operatingsystem} not supported")
  validate_absolute_path($install_dir)
  validate_re($mirror_url, '^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$', "${mirror_url} is not a valid url")
  validate_bool($install_java)
  validate_absolute_path($package_dir)
  validate_bool($service_restart)

  class { 'kafka::consumer::install': } ->
  class { 'kafka::consumer::config': } ->
  class { 'kafka::consumer::service': } ->
  Class['kafka::consumer']
}
