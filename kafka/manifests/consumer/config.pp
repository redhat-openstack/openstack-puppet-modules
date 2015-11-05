# Author::    Liam Bennett  (mailto:lbennett@opentable.com)
# Copyright:: Copyright (c) 2013 OpenTable Inc
# License::   MIT

# == Class: kafka::consumer::config
#
# This private class is meant to be called from `kafka::consumer`.
# It manages the consumer config files
#
define kafka::consumer::config(
  $config = {},
  $service_restart = $kafka::consumer::service_restart
) {

  $consumer_config = deep_merge($kafka::params::consumer_config_defaults, $config)

  $config_notify = $service_restart ? {
    true  => Service['kafka'],
    false => undef
  }

  file { "/opt/kafka/config/${name}.properties":
    ensure  => present,
    mode    => '0755',
    content => template('kafka/consumer.properties.erb'),
    require => File['/opt/kafka/config'],
    notify  => $config_notify
  }

}
