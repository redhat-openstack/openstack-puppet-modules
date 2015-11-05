# Author::    Liam Bennett  (mailto:lbennett@opentable.com)
# Copyright:: Copyright (c) 2013 OpenTable Inc
# License::   MIT

# == Class: kafka::broker::config
#
# This private class is meant to be called from `kafka::broker`.
# It manages the broker config files
#
class kafka::broker::config(
  $install_dir = $kafka::broker::install_dir,
  $service_restart = $kafka::broker::service_restart
) {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  $server_config = deep_merge($kafka::params::broker_config_defaults, $kafka::broker::config)

  $config_notify = $service_restart ? {
    true  => Service['kafka'],
    false => undef
  }

  file { '/opt/kafka/config/server.properties':
    owner   => 'kafka',
    group   => 'kafka',
    mode    => '0644',
    alias   => 'kafka-cfg',
    require => [ Exec['untar-kafka'], File['/opt/kafka'] ],
    content => template('kafka/server.properties.erb'),
    notify  => $config_notify
  }
}
