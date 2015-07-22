# Install and configure DataStax OpsCenter
#
# See the module README for details on how to use.
class cassandra::opscenter (
    $authentication_enabled            = 'False',
    $ensure                            = present,
    $config_file                       = '/etc/opscenter/opscenterd.conf',
    $package_name                      = 'opscenter',
    $service_enable                    = true,
    $service_ensure                    = 'running',
    $service_name                      = 'opscenterd',
    $stat_reporter_interval            = undef,
    $webserver_interface               = '0.0.0.0',
    $webserver_port                    = 8888,
    $webserver_ssl_certfile            = undef,
    $webserver_ssl_keyfile             = undef,
    $webserver_ssl_port                = undef,
    $webserver_staticdir               = undef,
    $webserver_sub_process_timeout     = undef,
    $webserver_tarball_process_timeout = undef
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
    value   => $webserver_port
  }

  cassandra::opscenter::setting { 'webserver interface':
    path    => $config_file,
    section => 'webserver',
    setting => 'interface',
    value   => $webserver_interface
  }

  cassandra::opscenter::setting { 'webserver ssl_keyfile':
    path    => $config_file,
    section => 'webserver',
    setting => 'ssl_keyfile',
    value   => $webserver_ssl_keyfile
  }

  cassandra::opscenter::setting { 'webserver ssl_certfile':
    path    => $config_file,
    section => 'webserver',
    setting => 'ssl_certfile',
    value   => $webserver_ssl_certfile
  }

  cassandra::opscenter::setting { 'webserver ssl_port':
    path    => $config_file,
    section => 'webserver',
    setting => 'ssl_port',
    value   => $webserver_ssl_port
  }

  service { 'opscenterd':
    ensure => $service_ensure,
    name   => $service_name,
    enable => $service_enable,
  }
}
