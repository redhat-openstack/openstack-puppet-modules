# == Class: cassandra
#
# Please see the README for this module for full details of what this class
# does as part of the module and how to use it.
#
class cassandra (
  $authenticator                         = 'AllowAllAuthenticator',
  $authorizer                            = 'AllowAllAuthorizer',
  $auto_snapshot                         = true,
  $cassandra_opt_package_name            = undef,
  $cassandra_opt_package_ensure          = 'present',
  $cassandra_package_ensure              = 'present',
  $cassandra_package_name                = 'dsc21',
  $cassandra_yaml_tmpl                   = 'cassandra/cassandra.yaml.erb',
  $client_encryption_enabled             = false,
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
  $hinted_handoff_enabled                = true,
  $incremental_backups                   = false,
  $internode_compression                 = 'all',
  $java_package_ensure                   = 'present',
  $java_package_name                     = undef,
  $listen_address                        = 'localhost',
  $manage_dsc_repo                       = false,
  $manage_service                        = true,
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
  $snapshot_before_compaction            = false,
  $start_native_transport                = true,
  $start_rpc                             = true,
  $storage_port                          = 7000
  ) {

  class { 'cassandra::install':
    cassandra_package_ensure     => $cassandra_package_ensure,
    cassandra_package_name       => $cassandra_package_name,
    cassandra_opt_package_ensure => $cassandra_opt_package_ensure,
    cassandra_opt_package_name   => $cassandra_opt_package_name,
    java_package_ensure          => $java_package_ensure,
    java_package_name            => $java_package_name,
    manage_dsc_repo              => $manage_dsc_repo,
  }

  $config_file = "${config_path}/cassandra.yaml"

  # A hack for long arguments
  $clt_enc_keystore_pass = $client_encryption_keystore_password
  $svr_enc_keystore_pass = $server_encryption_keystore_password
  $svr_enc_trtstore_pass = $server_encryption_truststore_password

  class { 'cassandra::config':
    authenticator                         => $authenticator,
    authorizer                            => $authorizer,
    auto_snapshot                         => $auto_snapshot,
    cassandra_package_name                => $cassandra_package_name,
    cassandra_yaml_tmpl                   => $cassandra_yaml_tmpl,
    client_encryption_enabled             => $client_encryption_enabled,
    client_encryption_keystore            => $client_encryption_keystore,
    client_encryption_keystore_password   => $clt_enc_keystore_pass,
    cluster_name                          => $cluster_name,
    commitlog_directory                   => $commitlog_directory,
    concurrent_counter_writes             => $concurrent_counter_writes,
    concurrent_reads                      => $concurrent_reads,
    concurrent_writes                     => $concurrent_writes,
    data_file_directories                 => $data_file_directories,
    disk_failure_policy                   => $disk_failure_policy,
    endpoint_snitch                       => $endpoint_snitch,
    hinted_handoff_enabled                => $hinted_handoff_enabled,
    incremental_backups                   => $incremental_backups,
    internode_compression                 => $internode_compression,
    listen_address                        => $listen_address,
    manage_service                        => $manage_service,
    native_transport_port                 => $native_transport_port,
    num_tokens                            => $num_tokens,
    partitioner                           => $partitioner,
    rpc_address                           => $rpc_address,
    rpc_port                              => $rpc_port,
    rpc_server_type                       => $rpc_server_type,
    saved_caches_directory                => $saved_caches_directory,
    seeds                                 => $seeds,
    server_encryption_internode           => $server_encryption_internode,
    server_encryption_keystore            => $server_encryption_keystore,
    server_encryption_keystore_password   => $svr_enc_keystore_pass,
    server_encryption_truststore          => $server_encryption_truststore,
    server_encryption_truststore_password => $svr_enc_trtstore_pass,
    service_name                          => $service_name,
    snapshot_before_compaction            => $snapshot_before_compaction,
    start_native_transport                => $start_native_transport,
    start_rpc                             => $start_rpc,
    storage_port                          => $storage_port,
  }
}
