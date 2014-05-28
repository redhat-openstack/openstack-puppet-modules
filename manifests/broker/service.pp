# == Class kafka::service
#
# This private class is meant to be called from kafka::broker. It ensures the service is running
#
class kafka::broker::service {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  file { '/etc/init.d/kafka':
    ensure  => present,
    mode    => '0755',
    content => template('kafka/init.erb')
  }

  service { 'kafka':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => File['/etc/init.d/kafka']
  }

}
