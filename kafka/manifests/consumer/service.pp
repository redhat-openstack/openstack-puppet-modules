# Author::    Liam Bennett  (mailto:lbennett@opentable.com)
# Copyright:: Copyright (c) 2013 OpenTable Inc
# License::   MIT

# == Class: kafka::consumer::service
#
# This private class is meant to be called from `kafka::consumer`.
# It manages the kafka-consumer service
#
class kafka::consumer::service(
  $config = $kafka::params::consumer_service_config
) {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  $consumer_service_config = deep_merge($config, $kafka::params::consumer_service_config)

  file { '/etc/init.d/kafka-consumer':
    ensure  => present,
    mode    => '0755',
    content => template('kafka/consumer.init.erb')
  }

  service { 'kafka-consumer':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => File['/etc/init.d/kafka-consumer']
  }
}
