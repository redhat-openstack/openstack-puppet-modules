# == Class kafka::broker::config
#
# This private class is called from kafka::broker to manage the configuration
#
class kafka::broker::config {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  $install_dir = "/usr/local/kafka-${kafka::broker::scala_version}-${kafka::broker::version}"

  $server_config = merge($kafka::params::broker_config_defaults, $kafka::broker::config)

  file { '/usr/local/kafka/config/server.properties':
    owner   => 'kafka',
    group   => 'kafka',
    mode    => '0644',
    alias   => 'kafka-cfg',
    require => [ Exec['untar-kafka'], File['/usr/local/kafka'] ],
    content => template('kafka/server.properties.erb')
  }

  file { '/var/log/kafka':
    ensure => directory,
    owner  => 'kafka',
    group  => 'kafka'
  }

}
