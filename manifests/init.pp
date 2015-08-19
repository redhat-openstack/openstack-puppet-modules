# == Class: cassandra
#
# Please see the README for this module for full details of what this class
# does as part of the module and how to use it.
#
class cassandra (
  $authenticator                         = 'AllowAllAuthenticator',
  $authorizer                            = 'AllowAllAuthorizer',
  $auto_snapshot                         = true,
  $cassandra_9822                        = false,
  $cassandra_yaml_tmpl                   = 'cassandra/cassandra.yaml.erb',
  $client_encryption_enabled             = false,
  $client_encryption_keystore            = 'conf/.keystore',
  $client_encryption_keystore_password   = 'cassandra',
  $cluster_name                          = 'Test Cluster',
  $commitlog_directory                   = '/var/lib/cassandra/commitlog',
  $concurrent_counter_writes             = 32,
  $concurrent_reads                      = 32,
  $concurrent_writes                     = 32,
  $config_path                           = undef,
  $data_file_directories                 = ['/var/lib/cassandra/data'],
  $dc                                    = 'DC1',
  $dc_suffix                             = undef,
  $disk_failure_policy                   = 'stop',
  $endpoint_snitch                       = 'SimpleSnitch',
  $hinted_handoff_enabled                = true,
  $incremental_backups                   = false,
  $internode_compression                 = 'all',
  $listen_address                        = 'localhost',
  $manage_dsc_repo                       = false,
  $native_transport_port                 = 9042,
  $num_tokens                            = 256,
  $package_ensure                        = 'present',
  $package_name                          = 'dsc22',
  $partitioner
    = 'org.apache.cassandra.dht.Murmur3Partitioner',
  $prefer_local                          = undef,
  $rack                                  = 'RAC1',
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
  $service_enable                        = true,
  $service_ensure                        = 'running',
  $service_name                          = 'cassandra',
  $snapshot_before_compaction            = false,
  $snitch_properties_file                = 'cassandra-rackdc.properties',
  $ssl_storage_port                      = 7001,
  $start_native_transport                = true,
  $start_rpc                             = true,
  $storage_port                          = 7000
  ) {
  if $manage_dsc_repo == true {
    $dep_014_url = 'https://github.com/locp/cassandra/wiki/DEP-014'
    require '::cassandra::datastax_repo'
    warning ("manage_dsc_repo has been deprecated. See ${dep_014_url}")
  }

  case $::osfamily {
    'RedHat': {
      if $config_path == undef {
        $cfg_path = '/etc/cassandra/default.conf'
      } else {
        $cfg_path = $config_path
      }
    }
    'Debian': {
      if $config_path == undef {
        $cfg_path = '/etc/cassandra'
      } else {
        $cfg_path = $config_path
      }

      # A workaround for CASSANDRA-9822
      if $cassandra_9822 == true {
        file { '/etc/init.d/cassandra':
          source => 'puppet:///modules/cassandra/CASSANDRA-9822/cassandra'
        }
      }
    }
    default: {
      fail("OS family ${::osfamily} not supported")
    }
  }

  package { $package_name:
    ensure => $package_ensure,
  }

  $config_file = "${cfg_path}/cassandra.yaml"

  file { $config_file:
    ensure  => present,
    owner   => 'cassandra',
    group   => 'cassandra',
    content => template($cassandra_yaml_tmpl),
    require => Package[$package_name],
    notify  => Service['cassandra'],
  }

  if $package_ensure != 'absent'
  and $package_ensure != 'purged' {
    service { 'cassandra':
      ensure  => running,
      name    => $service_name,
      enable  => true,
      require => Package[$package_name],
    }
  }

  $dc_rack_properties_file = "${cfg_path}/${snitch_properties_file}"

  ini_setting { 'rackdc.properties.dc':
    path    => $dc_rack_properties_file,
    section => '',
    setting => 'dc',
    value   => $dc,
    require => Package[$package_name],
    notify  => Service['cassandra']
  }

  ini_setting { 'rackdc.properties.rack':
    path    => $dc_rack_properties_file,
    section => '',
    setting => 'rack',
    value   => $rack,
    require => Package[$package_name],
    notify  => Service['cassandra']
  }

  if $dc_suffix != undef {
    ini_setting { 'rackdc.properties.dc_suffix':
      path    => $dc_rack_properties_file,
      section => '',
      setting => 'dc_suffix',
      value   => $dc_suffix,
      require => Package[$package_name],
      notify  => Service['cassandra']
    }
  }

  if $prefer_local != undef {
    ini_setting { 'rackdc.properties.prefer_local':
      path    => $dc_rack_properties_file,
      section => '',
      setting => 'prefer_local',
      value   => $prefer_local,
      require => Package[$package_name],
      notify  => Service['cassandra']
    }
  }
}
