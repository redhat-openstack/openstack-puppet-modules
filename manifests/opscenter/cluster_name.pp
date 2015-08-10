# cassandra::opscenter::cluster_name
define cassandra::opscenter::cluster_name(
  $cassandra_seed_hosts,
  $config_path                                = '/etc/opscenter/clusters',
  $storage_cassandra_api_port                 = undef,
  $storage_cassandra_bind_interface           = undef,
  $storage_cassandra_connection_pool_size     = undef,
  $storage_cassandra_connect_timeout          = undef,
  $storage_cassandra_cql_port                 = undef,
  $storage_cassandra_keyspace                 = undef,
  $storage_cassandra_local_dc_pref            = undef,
  $storage_cassandra_password                 = undef,
  $storage_cassandra_retry_delay              = undef,
  $storage_cassandra_send_rpc                 = undef,
  $storage_cassandra_ssl_ca_certs             = undef,
  $storage_cassandra_ssl_client_key           = undef,
  $storage_cassandra_ssl_client_pem           = undef,
  $storage_cassandra_ssl_validate             = undef,
  $storage_cassandra_used_hosts_per_remote_dc = undef,
  $storage_cassandra_username                 = undef,
  ) {
  file { $config_path:
    ensure  => directory,
    require => Package['opscenter'],
  }

  $cluster_file = "${config_path}/${title}.conf"

  Ini_setting {
    path              => $cluster_file,
    key_val_separator => ' = ',
    require           => File[$config_path],
    notify            => Service['opscenterd'],
  }

  if $cassandra_seed_hosts != undef {
    ini_setting { 'cassandra_seed_hosts':
      ensure  => present,
      section => 'cassandra',
      setting => 'seed_hosts',
      value   => $cassandra_seed_hosts
    }
  } else {
    ini_setting { 'cassandra_seed_hosts':
      ensure  => absent,
      section => 'cassandra',
      setting => 'seed_hosts'
    }
  }

  if $storage_cassandra_api_port != undef {
    ini_setting { 'storage_cassandra_api_port':
      ensure  => present,
      section => 'storage_cassandra',
      setting => 'api_port',
      value   => $storage_cassandra_api_port
    }
  } else {
    ini_setting { 'storage_cassandra_api_port':
      ensure  => absent,
      section => 'storage_cassandra',
      setting => 'api_port'
    }
  }

  if $storage_cassandra_bind_interface != undef {
    ini_setting { 'storage_cassandra_bind_interface':
      ensure  => present,
      section => 'storage_cassandra',
      setting => 'bind_interface',
      value   => $storage_cassandra_bind_interface
    }
  } else {
    ini_setting { 'storage_cassandra_bind_interface':
      ensure  => absent,
      section => 'storage_cassandra',
      setting => 'bind_interface'
    }
  }

  if $storage_cassandra_connection_pool_size != undef {
    ini_setting { 'storage_cassandra_connection_pool_size':
      ensure  => present,
      section => 'storage_cassandra',
      setting => 'connection_pool_size',
      value   => $storage_cassandra_connection_pool_size
    }
  } else {
    ini_setting { 'storage_cassandra_connection_pool_size':
      ensure  => absent,
      section => 'storage_cassandra',
      setting => 'connection_pool_size'
    }
  }

  if $storage_cassandra_connect_timeout != undef {
    ini_setting { 'storage_cassandra_connect_timeout':
      ensure  => present,
      section => 'storage_cassandra',
      setting => 'connect_timeout',
      value   => $storage_cassandra_connect_timeout
    }
  } else {
    ini_setting { 'storage_cassandra_connect_timeout':
      ensure  => absent,
      section => 'storage_cassandra',
      setting => 'connect_timeout'
    }
  }

  if $storage_cassandra_cql_port != undef {
    ini_setting { 'storage_cassandra_cql_port':
      ensure  => present,
      section => 'storage_cassandra',
      setting => 'cql_port',
      value   => $storage_cassandra_cql_port
    }
  } else {
    ini_setting { 'storage_cassandra_cql_port':
      ensure  => absent,
      section => 'storage_cassandra',
      setting => 'cql_port'
    }
  }

  if $storage_cassandra_keyspace != undef {
    ini_setting { 'storage_cassandra_keyspace':
      ensure  => present,
      section => 'storage_cassandra',
      setting => 'keyspace',
      value   => $storage_cassandra_keyspace
    }
  } else {
    ini_setting { 'storage_cassandra_keyspace':
      ensure  => absent,
      section => 'storage_cassandra',
      setting => 'keyspace'
    }
  }

  if $storage_cassandra_local_dc_pref != undef {
    ini_setting { 'storage_cassandra_local_dc_pref':
      ensure  => present,
      section => 'storage_cassandra',
      setting => 'local_dc_pref',
      value   => $storage_cassandra_local_dc_pref
    }
  } else {
    ini_setting { 'storage_cassandra_local_dc_pref':
      ensure  => absent,
      section => 'storage_cassandra',
      setting => 'local_dc_pref'
    }
  }

  if $storage_cassandra_password != undef {
    ini_setting { 'storage_cassandra_password':
      ensure  => present,
      section => 'storage_cassandra',
      setting => 'password',
      value   => $storage_cassandra_password
    }
  } else {
    ini_setting { 'storage_cassandra_password':
      ensure  => absent,
      section => 'storage_cassandra',
      setting => 'password'
    }
  }

  if $storage_cassandra_retry_delay != undef {
    ini_setting { 'storage_cassandra_retry_delay':
      ensure  => present,
      section => 'storage_cassandra',
      setting => 'retry_delay',
      value   => $storage_cassandra_retry_delay
    }
  } else {
    ini_setting { 'storage_cassandra_retry_delay':
      ensure  => absent,
      section => 'storage_cassandra',
      setting => 'retry_delay'
    }
  }

  if $storage_cassandra_send_rpc != undef {
    ini_setting { 'storage_cassandra_send_rpc':
      ensure  => present,
      section => 'storage_cassandra',
      setting => 'send_rpc',
      value   => $storage_cassandra_send_rpc
    }
  } else {
    ini_setting { 'storage_cassandra_send_rpc':
      ensure  => absent,
      section => 'storage_cassandra',
      setting => 'send_rpc'
    }
  }

  if $storage_cassandra_ssl_ca_certs != undef {
    ini_setting { 'storage_cassandra_ssl_ca_certs':
      ensure  => present,
      section => 'storage_cassandra',
      setting => 'ssl_ca_certs',
      value   => $storage_cassandra_ssl_ca_certs
    }
  } else {
    ini_setting { 'storage_cassandra_ssl_ca_certs':
      ensure  => absent,
      section => 'storage_cassandra',
      setting => 'ssl_ca_certs'
    }
  }

  if $storage_cassandra_ssl_client_key != undef {
    ini_setting { 'storage_cassandra_ssl_client_key':
      ensure  => present,
      section => 'storage_cassandra',
      setting => 'ssl_client_key',
      value   => $storage_cassandra_ssl_client_key
    }
  } else {
    ini_setting { 'storage_cassandra_ssl_client_key':
      ensure  => absent,
      section => 'storage_cassandra',
      setting => 'ssl_client_key'
    }
  }

  if $storage_cassandra_ssl_client_pem != undef {
    ini_setting { 'storage_cassandra_ssl_client_pem':
      ensure  => present,
      section => 'storage_cassandra',
      setting => 'ssl_client_pem',
      value   => $storage_cassandra_ssl_client_pem
    }
  } else {
    ini_setting { 'storage_cassandra_ssl_client_pem':
      ensure  => absent,
      section => 'storage_cassandra',
      setting => 'ssl_client_pem'
    }
  }

  if $storage_cassandra_ssl_validate != undef {
    ini_setting { 'storage_cassandra_ssl_validate':
      ensure  => present,
      section => 'storage_cassandra',
      setting => 'ssl_validate',
      value   => $storage_cassandra_ssl_validate
    }
  } else {
    ini_setting { 'storage_cassandra_ssl_validate':
      ensure  => absent,
      section => 'storage_cassandra',
      setting => 'ssl_validate'
    }
  }

  if $storage_cassandra_used_hosts_per_remote_dc != undef {
    ini_setting { 'storage_cassandra_used_hosts_per_remote_dc':
      ensure  => present,
      section => 'storage_cassandra',
      setting => 'used_hosts_per_remote_dc',
      value   => $storage_cassandra_used_hosts_per_remote_dc
    }
  } else {
    ini_setting { 'storage_cassandra_used_hosts_per_remote_dc':
      ensure  => absent,
      section => 'storage_cassandra',
      setting => 'used_hosts_per_remote_dc'
    }
  }

  if $storage_cassandra_username != undef {
    ini_setting { 'storage_cassandra_username':
      ensure  => present,
      section => 'storage_cassandra',
      setting => 'username',
      value   => $storage_cassandra_username
    }
  } else {
    ini_setting { 'storage_cassandra_username':
      ensure  => absent,
      section => 'storage_cassandra',
      setting => 'username'
    }
  }

}
