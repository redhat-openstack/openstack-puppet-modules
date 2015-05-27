# == Class: cassandra
#
# Please see the README for this module for full details of what this class
# does as part of the module and how to use it.
#
class cassandra (
  $authenticator                         = 'AllowAllAuthenticator',
  $authorizer                            = 'AllowAllAuthorizer',
  $auto_snapshot                         = 'true',
  $cassandra_opt_package_name            = undef,
  $cassandra_opt_package_ensure          = 'present',
  $cassandra_package_ensure              = 'present',
  $cassandra_package_name                = 'dsc21',
  $cassandra_yaml_tmpl                   = 'cassandra/cassandra.yaml.erb',
  $client_encryption_enabled             = 'false',
  $client_encryption_keystore            = 'conf/.keystore',
  $client_encryption_keystore_password   = 'cassandra',
  $cluster_name                          = 'Test Cluster',
  $commitlog_directory                   = '/var/lib/cassandra/commitlog',
  $concurrent_counter_writes             = 32,
  $concurrent_reads                      = 32,
  $concurrent_writes                     = 32,
  $config_path                           = '/etc/cassandra/default.conf',
  $data_file_directories                 = ['/var/lib/cassandra/data'],
  $disk_failure_policy                   = 'stop',
  $endpoint_snitch                       = 'SimpleSnitch',
  $hinted_handoff_enabled                = 'true',
  $incremental_backups                   = 'false',
  $internode_compression                 = 'all',
  $java_package_ensure                   = 'present',
  $java_package_name                     = undef,
  $listen_address                        = 'localhost',
  $manage_dsc_repo                       = 'false',
  $manage_service                        = 'true',
  $native_transport_port                 = 9042,
  $num_tokens                            = 256,
  $partitioner
    = 'org.apache.cassandra.dht.Murmur3Partitioner',
  $rpc_address                           = 'localhost',
  $rpc_port                              = 9160,
  $rpc_server_type                       = 'sync',
  $saved_caches_directory                = '/var/lib/cassandra/saved_caches',
  $seeds                                 = '127.0.0.1',
  $server_encryption_internode           = 'none',
  $server_encryption_keystore            = 'conf/.keystore',
  $server_encryption_keystore_password   = 'cassandra',
  $server_encryption_truststore          = 'conf/.truststore',
  $server_encryption_truststore_password = 'cassandra',
  $service_name                          = 'cassandra',
  $snapshot_before_compaction            = 'false',
  $start_native_transport                = 'true',
  $start_rpc                             = 'true',
  $storage_port                          = 7000
  ) {

  case $::osfamily {
    'RedHat': {
      if $manage_dsc_repo == true {
        yumrepo { 'datastax':
          ensure   => present,
          descr    => 'DataStax Repo for Apache Cassandra',
          baseurl  => 'http://rpm.datastax.com/community',
          enabled  => 1,
          gpgcheck => 0,
          before   => Package[ $cassandra_package_name ],
        }
      }
    }
    default: {
      fail("OS family ${::osfamily} not supported")
    }
  }

  if $java_package_name != undef {
    package { $java_package_name:
      ensure => $java_package_ensure,
      before => Package[ $cassandra_package_name ],
    }
  }

  package { $cassandra_package_name:
    ensure => $cassandra_package_ensure,
  }

  if $cassandra_opt_package_name != undef {
    package { $cassandra_opt_package_name:
      ensure  => $cassandra_opt_package_ensure,
      require => Package[$cassandra_package_name],
    }
  }

  $config_file = "${config_path}/cassandra.yaml"

  if $manage_service == true {
    file { $config_file:
      ensure  => file,
      owner   => 'cassandra',
      group   => 'cassandra',
      content => template($cassandra_yaml_tmpl),
      require => Package[$cassandra_package_name],
      notify  => Service['cassandra'],
    }

    service { 'cassandra':
      ensure  => running,
      name    => $service_name,
      enable  => true,
      require => Package[$cassandra_package_name],
    }
  } else {
    file { $config_file:
      ensure  => file,
      owner   => 'cassandra',
      group   => 'cassandra',
      content => template($cassandra_yaml_tmpl),
      require => Package[$cassandra_package_name],
    }
  }
}
