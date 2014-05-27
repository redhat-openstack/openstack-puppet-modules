# == Class kafka::service
#
# This private class is meant to be called from kafka::broker. It ensures the service is running
#
class kafka::broker::service {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  case downcase($::osfamily) {
    'debian': {
      $config_default = '/etc/default/kafka'
    }
    'redhat': {
      $config_default = '/etc/sysconfig/kafka'
    }
    default: {
      fail("unsupported osfamily ${::osfamily}")
    }
  }

  file { 'kafka-config-default':
    ensure  => present,
    path    => $config_default,
    content => template('kafka/kafka.default.erb')
  }

  file { '/etc/init.d/kafka':
    ensure  => present,
    mode    => '0755',
    content => template("kafka/init.${::osfamily}.erb")
  }

  service { 'kafka':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => [ File['kafka-config-default'], File['/etc/init.d/kafka'] ]
  }

}
