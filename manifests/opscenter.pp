# Install and configure DataStax OpsCenter
#
# See the module README for details on how to use.
class cassandra::opscenter (
    $authentication_audit_auth         = undef,
    $authentication_audit_pattern      = undef,
    $authentication_enabled            = 'False',
    $authentication_method             = undef,
    $authentication_passwd_db          = undef,
    $authentication_timeout            = undef,
    $ensure                            = present,
    $config_file                       = '/etc/opscenter/opscenterd.conf',
    $package_name                      = 'opscenter',
    $service_enable                    = true,
    $service_ensure                    = 'running',
    $service_name                      = 'opscenterd',
    $logging_level                     = undef,
    $logging_log_length                = undef,
    $logging_log_path                  = undef,
    $logging_max_rotate                = undef,
    $logging_resource_usage_interval   = undef,
    $stat_reporter_initial_sleep       = undef,
    $stat_reporter_interval            = undef,
    $stat_reporter_report_file         = undef,
    $stat_reporter_ssl_key             = undef,
    $webserver_interface               = '0.0.0.0',
    $webserver_log_path                = undef,
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

  service { 'opscenterd':
    ensure => $service_ensure,
    name   => $service_name,
    enable => $service_enable,
  }

  cassandra::opscenter::setting { 'authentication audit_auth':
    path    => $config_file,
    section => 'authentication',
    setting => 'audit_auth',
    value   => $authentication_audit_auth
  }

  cassandra::opscenter::setting { 'authentication audit_pattern':
    path    => $config_file,
    section => 'authentication',
    setting => 'audit_pattern',
    value   => $authentication_audit_pattern
  }

  cassandra::opscenter::setting { 'authentication method':
    path    => $config_file,
    section => 'authentication',
    setting => 'method',
    value   => $authentication_method
  }

  cassandra::opscenter::setting { 'authentication enabled':
    path    => $config_file,
    section => 'authentication',
    setting => 'enabled',
    value   => $authentication_enabled
  }

  cassandra::opscenter::setting { 'authentication passwd_db':
    path    => $config_file,
    section => 'authentication',
    setting => 'passwd_db',
    value   => $authentication_passwd_db
  }

  cassandra::opscenter::setting { 'authentication timeout':
    path    => $config_file,
    section => 'authentication',
    setting => 'timeout',
    value   => $authentication_timeout
  }

  cassandra::opscenter::setting { 'stat_reporter initial_sleep':
    path    => $config_file,
    section => 'stat_reporter',
    setting => 'initial_sleep',
    value   => $stat_reporter_initial_sleep
  }

  cassandra::opscenter::setting { 'stat_reporter interval':
    path    => $config_file,
    section => 'stat_reporter',
    setting => 'interval',
    value   => $stat_reporter_interval
  }

  cassandra::opscenter::setting { 'stat_reporter report_file':
    path    => $config_file,
    section => 'stat_reporter',
    setting => 'report_file',
    value   => $stat_reporter_report_file
  }

  cassandra::opscenter::setting { 'stat_reporter ssl_key':
    path    => $config_file,
    section => 'stat_reporter',
    setting => 'ssl_key',
    value   => $stat_reporter_ssl_key
  }

  cassandra::opscenter::setting { 'webserver interface':
    path    => $config_file,
    section => 'webserver',
    setting => 'interface',
    value   => $webserver_interface
  }

  cassandra::opscenter::setting { 'webserver log_path':
    path    => $config_file,
    section => 'webserver',
    setting => 'log_path',
    value   => $webserver_log_path
  }

  cassandra::opscenter::setting { 'webserver port':
    path    => $config_file,
    section => 'webserver',
    setting => 'port',
    value   => $webserver_port
  }

  cassandra::opscenter::setting { 'webserver ssl_certfile':
    path    => $config_file,
    section => 'webserver',
    setting => 'ssl_certfile',
    value   => $webserver_ssl_certfile
  }

  cassandra::opscenter::setting { 'webserver ssl_keyfile':
    path    => $config_file,
    section => 'webserver',
    setting => 'ssl_keyfile',
    value   => $webserver_ssl_keyfile
  }

  cassandra::opscenter::setting { 'webserver ssl_port':
    path    => $config_file,
    section => 'webserver',
    setting => 'ssl_port',
    value   => $webserver_ssl_port
  }

  cassandra::opscenter::setting { 'webserver staticdir':
    path    => $config_file,
    section => 'webserver',
    setting => 'staticdir',
    value   => $webserver_staticdir
  }

  cassandra::opscenter::setting { 'webserver sub_process_timeout':
    path    => $config_file,
    section => 'webserver',
    setting => 'sub_process_timeout',
    value   => $webserver_sub_process_timeout
  }

  cassandra::opscenter::setting { 'webserver tarball_process_timeout':
    path    => $config_file,
    section => 'webserver',
    setting => 'tarball_process_timeout',
    value   => $webserver_tarball_process_timeout
  }
}
