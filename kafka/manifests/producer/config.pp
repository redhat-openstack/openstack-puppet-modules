# Author::    Liam Bennett  (mailto:lbennett@opentable.com)
# Copyright:: Copyright (c) 2013 OpenTable Inc
# License::   MIT

# == Class: kafka::producer::config
#
# This private class is meant to be called from `kafka::producer`.
# It manages the producer config files
#
class kafka::producer::config(
  $config = {},
  $service_restart = $kafka::producer::service_restart
) {

  $producer_config = deep_merge($kafka::params::producer_config_defaults, $config)

  $config_notify = $service_restart ? {
    true  => Service['kafka'],
    false => undef
  }

  file { '/opt/kafka/config/producer.properties':
    ensure  => present,
    mode    => '0755',
    content => template('kafka/producer.properties.erb'),
    require => File['/opt/kafka/config'],
    notify  => $config_notify
  }

}
