# Install and configure DataStax OpsCenter
#
# See the module README for details on how to use.
class cassandra::opscenter (
    $authentication_enabled = 'False',
    $ensure                 = present,
    $config_file            = '/etc/opscenter/opscenterd.conf',
    $interface              = '0.0.0.0',
    $package_name           = 'opscenter',
    $port                   = 8888,
    $service_enable         = true,
    $service_ensure         = 'running',
    $service_name           = 'opscenterd',
    $ssl_keyfile            = undef,
    $ssl_certfile           = undef,
    $ssl_port               = undef,
    $stat_reporter_interval = undef
  ) {
  package { 'opscenter':
    ensure  => $ensure,
    name    => $package_name,
    require => Class['cassandra'],
    before  => Service['opscenterd']
  }
  
  cassandra::opscenter::setting { 'authentication enabled':
    path    => $config_file,
    section => 'authentication',
    setting => 'enabled',
    value   => $authentication_enabled,
  }

  cassandra::opscenter::setting { 'webserver port':
    path    => $config_file,
    section => 'webserver',
    setting => 'port',
    value   => $port
  }

  cassandra::opscenter::setting { 'webserver interface':
    path    => $config_file,
    section => 'webserver',
    setting => 'interface',
    value   => $interface
  }

  cassandra::opscenter::setting { 'webserver ssl_keyfile':
    path    => $config_file,
    section => 'webserver',
    setting => 'ssl_keyfile',
    value   => $ssl_keyfile
  }

  cassandra::opscenter::setting { 'webserver ssl_certfile':
    path    => $config_file,
    section => 'webserver',
    setting => 'ssl_certfile',
    value   => $ssl_certfile
  }

  cassandra::opscenter::setting { 'webserver ssl_port':
    path    => $config_file,
    section => 'webserver',
    setting => 'ssl_port',
    value   => $ssl_port
  }

  service { 'opscenterd':
    ensure => $service_ensure,
    name   => $service_name,
    enable => $service_enable,
  }
}
