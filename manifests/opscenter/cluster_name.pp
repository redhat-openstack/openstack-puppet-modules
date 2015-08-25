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
  if ! defined( File[$config_path] ) {
    file { $config_path:
      ensure => directory
    }
  }

  $cluster_file = "${config_path}/${title}.conf"

  if $cassandra_seed_hosts != undef {
    ini_setting { "${title}:cassandra_seed_hosts":
      ensure            => present,
      section           => 'cassandra',
      setting           => 'seed_hosts',
      value             => $cassandra_seed_hosts,
      path              => $cluster_file,
      key_val_separator => ' = ',
      require           => File[$config_path],
      notify            => Service['opscenterd'],
    }
  } else {
    ini_setting { "${title}:cassandra_seed_hosts":
      ensure            => absent,
      section           => 'cassandra',
      setting           => 'seed_hosts',
      path              => $cluster_file,
      key_val_separator => ' = ',
      require           => File[$config_path],
      notify            => Service['opscenterd'],
    }
  }

  if $storage_cassandra_api_port != undef {
    ini_setting { "${title}:storage_cassandra_api_port":
      ensure            => present,
      section           => 'storage_cassandra',
      setting           => 'api_port',
      value             => $storage_cassandra_api_port,
      path              => $cluster_file,
      key_val_separator => ' = ',
      require           => File[$config_path],
      notify            => Service['opscenterd'],
    }
  } else {
    ini_setting { "${title}:storage_cassandra_api_port":
      ensure            => absent,
      section           => 'storage_cassandra',
      setting           => 'api_port',
      path              => $cluster_file,
      key_val_separator => ' = ',
      require           => File[$config_path],
      notify            => Service['opscenterd'],
    }
  }

  if $storage_cassandra_bind_interface != undef {
    ini_setting { "${title}:storage_cassandra_bind_interface":
      ensure            => present,
      section           => 'storage_cassandra',
      setting           => 'bind_interface',
      value             => $storage_cassandra_bind_interface,
      path              => $cluster_file,
      key_val_separator => ' = ',
      require           => File[$config_path],
      notify            => Service['opscenterd'],
    }
  } else {
    ini_setting { "${title}:storage_cassandra_bind_interface":
      ensure            => absent,
      section           => 'storage_cassandra',
      setting           => 'bind_interface',
      path              => $cluster_file,
      key_val_separator => ' = ',
      require           => File[$config_path],
      notify            => Service['opscenterd'],
    }
  }

  if $storage_cassandra_connection_pool_size != undef {
    ini_setting { "${title}:storage_cassandra_connection_pool_size":
      ensure            => present,
      section           => 'storage_cassandra',
      setting           => 'connection_pool_size',
      value             => $storage_cassandra_connection_pool_size,
      path              => $cluster_file,
      key_val_separator => ' = ',
      require           => File[$config_path],
      notify            => Service['opscenterd'],
    }
  } else {
    ini_setting { "${title}:storage_cassandra_connection_pool_size":
      ensure            => absent,
      section           => 'storage_cassandra',
      setting           => 'connection_pool_size',
      path              => $cluster_file,
      key_val_separator => ' = ',
      require           => File[$config_path],
      notify            => Service['opscenterd'],
    }
  }

  if $storage_cassandra_connect_timeout != undef {
    ini_setting { "${title}:storage_cassandra_connect_timeout":
      ensure            => present,
      section           => 'storage_cassandra',
      setting           => 'connect_timeout',
      value             => $storage_cassandra_connect_timeout,
      path              => $cluster_file,
      key_val_separator => ' = ',
      require           => File[$config_path],
      notify            => Service['opscenterd'],
    }
  } else {
    ini_setting { "${title}:storage_cassandra_connect_timeout":
      ensure            => absent,
      section           => 'storage_cassandra',
      setting           => 'connect_timeout',
      path              => $cluster_file,
      key_val_separator => ' = ',
      require           => File[$config_path],
      notify            => Service['opscenterd'],
    }
  }

  if $storage_cassandra_cql_port != undef {
    ini_setting { "${title}:storage_cassandra_cql_port":
      ensure            => present,
      section           => 'storage_cassandra',
      setting           => 'cql_port',
      value             => $storage_cassandra_cql_port,
      path              => $cluster_file,
      key_val_separator => ' = ',
      require           => File[$config_path],
      notify            => Service['opscenterd'],
    }
  } else {
    ini_setting { "${title}:storage_cassandra_cql_port":
      ensure            => absent,
      section           => 'storage_cassandra',
      setting           => 'cql_port',
      path              => $cluster_file,
      key_val_separator => ' = ',
      require           => File[$config_path],
      notify            => Service['opscenterd'],
    }
  }

  if $storage_cassandra_keyspace != undef {
    ini_setting { "${title}:storage_cassandra_keyspace":
      ensure            => present,
      section           => 'storage_cassandra',
      setting           => 'keyspace',
      value             => $storage_cassandra_keyspace,
      path              => $cluster_file,
      key_val_separator => ' = ',
      require           => File[$config_path],
      notify            => Service['opscenterd'],
    }
  } else {
    ini_setting { "${title}:storage_cassandra_keyspace":
      ensure            => absent,
      section           => 'storage_cassandra',
      setting           => 'keyspace',
      path              => $cluster_file,
      key_val_separator => ' = ',
      require           => File[$config_path],
      notify            => Service['opscenterd'],
    }
  }

  if $storage_cassandra_local_dc_pref != undef {
    ini_setting { "${title}:storage_cassandra_local_dc_pref":
      ensure            => present,
      section           => 'storage_cassandra',
      setting           => 'local_dc_pref',
      value             => $storage_cassandra_local_dc_pref,
      path              => $cluster_file,
      key_val_separator => ' = ',
      require           => File[$config_path],
      notify            => Service['opscenterd'],
    }
  } else {
    ini_setting { "${title}:storage_cassandra_local_dc_pref":
      ensure            => absent,
      section           => 'storage_cassandra',
      setting           => 'local_dc_pref',
      path              => $cluster_file,
      key_val_separator => ' = ',
      require           => File[$config_path],
      notify            => Service['opscenterd'],
    }
  }

  if $storage_cassandra_password != undef {
    ini_setting { "${title}:storage_cassandra_password":
      ensure            => present,
      section           => 'storage_cassandra',
      setting           => 'password',
      value             => $storage_cassandra_password,
      path              => $cluster_file,
      key_val_separator => ' = ',
      require           => File[$config_path],
      notify            => Service['opscenterd'],
    }
  } else {
    ini_setting { "${title}:storage_cassandra_password":
      ensure            => absent,
      section           => 'storage_cassandra',
      setting           => 'password',
      path              => $cluster_file,
      key_val_separator => ' = ',
      require           => File[$config_path],
      notify            => Service['opscenterd'],
    }
  }

  if $storage_cassandra_retry_delay != undef {
    ini_setting { "${title}:storage_cassandra_retry_delay":
      ensure            => present,
      section           => 'storage_cassandra',
      setting           => 'retry_delay',
      value             => $storage_cassandra_retry_delay,
      path              => $cluster_file,
      key_val_separator => ' = ',
      require           => File[$config_path],
      notify            => Service['opscenterd'],
    }
  } else {
    ini_setting { "${title}:storage_cassandra_retry_delay":
      ensure            => absent,
      section           => 'storage_cassandra',
      setting           => 'retry_delay',
      path              => $cluster_file,
      key_val_separator => ' = ',
      require           => File[$config_path],
      notify            => Service['opscenterd'],
    }
  }

  if $storage_cassandra_send_rpc != undef {
    ini_setting { "${title}:storage_cassandra_send_rpc":
      ensure            => present,
      section           => 'storage_cassandra',
      setting           => 'send_rpc',
      value             => $storage_cassandra_send_rpc,
      path              => $cluster_file,
      key_val_separator => ' = ',
      require           => File[$config_path],
      notify            => Service['opscenterd'],
    }
  } else {
    ini_setting { "${title}:storage_cassandra_send_rpc":
      ensure            => absent,
      section           => 'storage_cassandra',
      setting           => 'send_rpc',
      path              => $cluster_file,
      key_val_separator => ' = ',
      require           => File[$config_path],
      notify            => Service['opscenterd'],
    }
  }

  if $storage_cassandra_ssl_ca_certs != undef {
    ini_setting { "${title}:storage_cassandra_ssl_ca_certs":
      ensure            => present,
      section           => 'storage_cassandra',
      setting           => 'ssl_ca_certs',
      value             => $storage_cassandra_ssl_ca_certs,
      path              => $cluster_file,
      key_val_separator => ' = ',
      require           => File[$config_path],
      notify            => Service['opscenterd'],
    }
  } else {
    ini_setting { "${title}:storage_cassandra_ssl_ca_certs":
      ensure            => absent,
      section           => 'storage_cassandra',
      setting           => 'ssl_ca_certs',
      path              => $cluster_file,
      key_val_separator => ' = ',
      require           => File[$config_path],
      notify            => Service['opscenterd'],
    }
  }

  if $storage_cassandra_ssl_client_key != undef {
    ini_setting { "${title}:storage_cassandra_ssl_client_key":
      ensure            => present,
      section           => 'storage_cassandra',
      setting           => 'ssl_client_key',
      value             => $storage_cassandra_ssl_client_key,
      path              => $cluster_file,
      key_val_separator => ' = ',
      require           => File[$config_path],
      notify            => Service['opscenterd'],
    }
  } else {
    ini_setting { "${title}:storage_cassandra_ssl_client_key":
      ensure            => absent,
      section           => 'storage_cassandra',
      setting           => 'ssl_client_key',
      path              => $cluster_file,
      key_val_separator => ' = ',
      require           => File[$config_path],
      notify            => Service['opscenterd'],
    }
  }

  if $storage_cassandra_ssl_client_pem != undef {
    ini_setting { "${title}:storage_cassandra_ssl_client_pem":
      ensure            => present,
      section           => 'storage_cassandra',
      setting           => 'ssl_client_pem',
      path              => $cluster_file,
      key_val_separator => ' = ',
      require           => File[$config_path],
      notify            => Service['opscenterd'],
      value             => $storage_cassandra_ssl_client_pem,
    }
  } else {
    ini_setting { "${title}:storage_cassandra_ssl_client_pem":
      ensure            => absent,
      section           => 'storage_cassandra',
      setting           => 'ssl_client_pem',
      path              => $cluster_file,
      key_val_separator => ' = ',
      require           => File[$config_path],
      notify            => Service['opscenterd'],
    }
  }

  if $storage_cassandra_ssl_validate != undef {
    ini_setting { "${title}:storage_cassandra_ssl_validate":
      ensure            => present,
      section           => 'storage_cassandra',
      setting           => 'ssl_validate',
      value             => $storage_cassandra_ssl_validate,
      path              => $cluster_file,
      key_val_separator => ' = ',
      require           => File[$config_path],
      notify            => Service['opscenterd'],
    }
  } else {
    ini_setting { "${title}:storage_cassandra_ssl_validate":
      ensure            => absent,
      section           => 'storage_cassandra',
      setting           => 'ssl_validate',
      path              => $cluster_file,
      key_val_separator => ' = ',
      require           => File[$config_path],
      notify            => Service['opscenterd'],
    }
  }

  if $storage_cassandra_used_hosts_per_remote_dc != undef {
    ini_setting { "${title}:storage_cassandra_used_hosts_per_remote_dc":
      ensure            => present,
      section           => 'storage_cassandra',
      setting           => 'used_hosts_per_remote_dc',
      value             => $storage_cassandra_used_hosts_per_remote_dc,
      path              => $cluster_file,
      key_val_separator => ' = ',
      require           => File[$config_path],
      notify            => Service['opscenterd'],
    }
  } else {
    ini_setting { "${title}:storage_cassandra_used_hosts_per_remote_dc":
      ensure            => absent,
      section           => 'storage_cassandra',
      setting           => 'used_hosts_per_remote_dc',
      path              => $cluster_file,
      key_val_separator => ' = ',
      require           => File[$config_path],
      notify            => Service['opscenterd'],
    }
  }

  if $storage_cassandra_username != undef {
    ini_setting { "${title}:storage_cassandra_username":
      ensure            => present,
      section           => 'storage_cassandra',
      setting           => 'username',
      value             => $storage_cassandra_username,
      path              => $cluster_file,
      key_val_separator => ' = ',
      require           => File[$config_path],
      notify            => Service['opscenterd'],
    }
  } else {
    ini_setting { "${title}:storage_cassandra_username":
      ensure            => absent,
      section           => 'storage_cassandra',
      setting           => 'username',
      path              => $cluster_file,
      key_val_separator => ' = ',
      require           => File[$config_path],
      notify            => Service['opscenterd'],
    }
  }
}
