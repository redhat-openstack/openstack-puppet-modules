# == Class: cassandra::config
#
# Please see the README for this module for full details of what this class
# does as part of the module and how to use it.
#
class cassandra::config (
  $authenticator,
  $authorizer,
  $auto_snapshot,
  $cassandra_package_name,
  $cassandra_yaml_tmpl,
  $client_encryption_enabled,
  $client_encryption_keystore,
  $client_encryption_keystore_password,
  $cluster_name,
  $commitlog_directory,
  $concurrent_counter_writes,
  $concurrent_reads,
  $concurrent_writes,
  $config_path,
  $data_file_directories,
  $datastax_agent_ensure,
  $datastax_agent_manage_service,
  $datastax_agent_service_name,
  $disk_failure_policy,
  $endpoint_snitch,
  $hinted_handoff_enabled,
  $incremental_backups,
  $internode_compression,
  $listen_address,
  $manage_service,
  $native_transport_port,
  $num_tokens,
  $partitioner,
  $rpc_address,
  $rpc_port,
  $rpc_server_type,
  $saved_caches_directory,
  $seeds,
  $server_encryption_internode,
  $server_encryption_keystore,
  $server_encryption_keystore_password,
  $server_encryption_truststore,
  $server_encryption_truststore_password,
  $service_name,
  $snapshot_before_compaction,
  $start_native_transport,
  $start_rpc,
  $storage_port,
  ) {

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

  if $datastax_agent_ensure != undef
  and $datastax_agent_ensure != 'absent'
  and $datastax_agent_ensure != 'purged' {
    if $datastax_agent_manage_service == true {
      service { $datastax_agent_service_name:
        ensure => running,
        enable => true,
      }
    }
  }
}
