# Author::    Liam Bennett  (mailto:lbennett@opentable.com)
# Copyright:: Copyright (c) 2013 OpenTable Inc
# License::   MIT

# == Class: kafka::mirror::service
#
# This private class is meant to be called from `kafka::mirror`.
# It manages the kafka-mirror service
#
class kafka::mirror::service(
  $consumer_configs = $kafka::params::consumer_configs,
  $num_streams = $kafka::params::num_streams,
  $producer_config = $kafka::params::producer_config,
  $num_producers = $kafka::params::num_producers,
  $whitelist = $kafka::params::whitelist,
  $blacklist = $kafka::params::blacklist
) {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  file { '/etc/init.d/kafka-mirror':
    ensure  => present,
    mode    => '0755',
    content => template('kafka/mirror.init.erb')
  }

  service { 'kafka-mirror':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => File['/etc/init.d/kafka-mirror']
  }
}
