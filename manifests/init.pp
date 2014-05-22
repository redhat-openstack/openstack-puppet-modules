# == Class: kafka
#
# Full description of class kafka here.
#
# === Parameters
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#
class kafka (
  $broker_id = $kafka::params::broker_id,
  $hostname = $kafka::params::hostname,
  $zookeeper_connect = $kafka::params::zookeeper_connect,
  $mirror_url = $kafka::params::mirror_url,
  $install_dir = $kafka::params::install_dir,
  $version = $kafka::params::version,
  $scala_version = $kafka::params::scala_version
) inherits kafka::params {

  # validate parameters here

  class { 'kafka::install': } ->
  class { 'kafka::config': } ~>
  class { 'kafka::service': } ->
  Class['kafka']
}
