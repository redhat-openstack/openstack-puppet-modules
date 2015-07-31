# Install and configure DataStax OpsCenter
#
# See the module README for details on how to use.
class cassandra::opscenter (
    $agents_agent_certfile                          = undef,
    $agents_agent_keyfile                           = undef,
    $agents_agent_keyfile_raw                       = undef,
    $agents_config_sleep                            = undef,
    $agents_fingerprint_throttle                    = undef,
    $agents_incoming_interface                      = undef,
    $agents_incoming_port                           = undef,
    $agents_install_throttle                        = undef,
    $agents_not_seen_threshold                      = undef,
    $agents_path_to_deb                             = undef,
    $agents_path_to_find_java                       = undef,
    $agents_path_to_installscript                   = undef,
    $agents_path_to_rpm                             = undef,
    $agents_path_to_sudowrap                        = undef,
    $agents_reported_interface                      = undef,
    $agents_runs_sudo                               = undef,
    $agents_scp_executable                          = undef,
    $agents_ssh_executable                          = undef,
    $agents_ssh_keygen_executable                   = undef,
    $agents_ssh_keyscan_executable                  = undef,
    $agents_ssh_port                                = undef,
    $agents_ssh_sys_known_hosts_file                = undef,
    $agents_ssh_user_known_hosts_file               = undef,
    $agents_ssl_certfile                            = undef,
    $agents_ssl_keyfile                             = undef,
    $agents_tmp_dir                                 = undef,
    $agents_use_ssl                                 = undef,
    $authentication_audit_auth                      = undef,
    $authentication_audit_pattern                   = undef,
    $authentication_enabled                         = 'False',
    $authentication_method                          = undef,
    $authentication_passwd_db                       = undef,
    $authentication_timeout                         = undef,
    $cloud_accepted_certs                           = undef,
    $clusters_add_cluster_timeout                   = undef,
    $clusters_startup_sleep                         = undef,
    $config_file
      = '/etc/opscenter/opscenterd.conf',
    $definitions_auto_update                        = undef,
    $definitions_definitions_dir                    = undef,
    $definitions_download_filename                  = undef,
    $definitions_download_host                      = undef,
    $definitions_download_port                      = undef,
    $definitions_hash_filename                      = undef,
    $definitions_sleep                              = undef,
    $definitions_ssl_certfile                       = undef,
    $definitions_use_ssl                            = undef,
    $ensure                                         = present,
    $failover_configuration_directory               = undef,
    $failover_heartbeat_fail_window                 = undef,
    $failover_heartbeat_period                      = undef,
    $failover_heartbeat_reply_period                = undef,
    $hadoop_base_job_tracker_proxy_port             = undef,
    $package_name                                   = 'opscenter',
    $provisioning_agent_install_timeout             = undef,
    $provisioning_keyspace_timeout                  = undef,
    $provisioning_private_key_dir                   = undef,
    $service_enable                                 = true,
    $service_ensure                                 = 'running',
    $service_name                                   = 'opscenterd',
    $ldap_admin_group_name                          = undef,
    $ldap_connection_timeout                        = undef,
    $ldap_debug_ssl                                 = undef,
    $ldap_group_name_attribute                      = undef,
    $ldap_group_search_base                         = undef,
    $ldap_group_search_filter                       = undef,
    $ldap_group_search_type                         = undef,
    $ldap_ldap_security                             = undef,
    $ldap_opt_referrals                             = undef,
    $ldap_protocol_version                          = undef,
    $ldap_search_dn                                 = undef,
    $ldap_search_password                           = undef,
    $ldap_server_host                               = undef,
    $ldap_server_port                               = undef,
    $ldap_ssl_cacert                                = undef,
    $ldap_ssl_cert                                  = undef,
    $ldap_ssl_key                                   = undef,
    $ldap_tls_demand                                = undef,
    $ldap_tls_reqcert                               = undef,
    $ldap_uri_scheme                                = undef,
    $ldap_user_memberof_attribute                   = undef,
    $ldap_user_search_base                          = undef,
    $ldap_user_search_filter                        = undef,
    $logging_level                                  = undef,
    $logging_log_length                             = undef,
    $logging_log_path                               = undef,
    $logging_max_rotate                             = undef,
    $logging_resource_usage_interval                = undef,
    $repair_service_alert_on_repair_failure         = undef,
    $repair_service_cluster_stabilization_period    = undef,
    $repair_service_error_logging_window            = undef,
    $repair_service_incremental_err_alert_threshold = undef,
    $repair_service_incremental_range_repair        = undef,
    $repair_service_incremental_repair_tables       = undef,
    $repair_service_ks_update_period                = undef,
    $repair_service_log_directory                   = undef,
    $repair_service_log_length                      = undef,
    $repair_service_max_err_threshold               = undef,
    $repair_service_max_parallel_repairs            = undef,
    $repair_service_max_pending_repairs             = undef,
    $repair_service_max_rotate                      = undef,
    $repair_service_min_repair_time                 = undef,
    $repair_service_min_throughput                  = undef,
    $repair_service_num_recent_throughputs          = undef,
    $repair_service_persist_directory               = undef,
    $repair_service_persist_period                  = undef,
    $repair_service_restart_period                  = undef,
    $repair_service_single_repair_timeout           = undef,
    $repair_service_single_task_err_threshold       = undef,
    $repair_service_snapshot_override               = undef,
    $request_tracker_queue_size                     = undef,
    $stat_reporter_initial_sleep                    = undef,
    $stat_reporter_interval                         = undef,
    $stat_reporter_report_file                      = undef,
    $stat_reporter_ssl_key                          = undef,
    $webserver_interface                            = '0.0.0.0',
    $webserver_log_path                             = undef,
    $webserver_port                                 = 8888,
    $webserver_ssl_certfile                         = undef,
    $webserver_ssl_keyfile                          = undef,
    $webserver_ssl_port                             = undef,
    $webserver_staticdir                            = undef,
    $webserver_sub_process_timeout                  = undef,
    $webserver_tarball_process_timeout              = undef
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

  cassandra::opscenter::setting { 'agents agent_certfile':
    path    => $config_file,
    section => 'agents',
    setting => 'agent_certfile',
    value   => $agents_agent_certfile
  }

  cassandra::opscenter::setting { 'agents agent_keyfile':
    path    => $config_file,
    section => 'agents',
    setting => 'agent_keyfile',
    value   => $agents_agent_keyfile
  }

  cassandra::opscenter::setting { 'agents agent_keyfile_raw':
    path    => $config_file,
    section => 'agents',
    setting => 'agent_keyfile_raw',
    value   => $agents_agent_keyfile_raw
  }

  cassandra::opscenter::setting { 'agents config_sleep':
    path    => $config_file,
    section => 'agents',
    setting => 'config_sleep',
    value   => $agents_config_sleep
  }

  cassandra::opscenter::setting { 'agents fingerprint_throttle':
    path    => $config_file,
    section => 'agents',
    setting => 'fingerprint_throttle',
    value   => $agents_fingerprint_throttle
  }

  cassandra::opscenter::setting { 'agents incoming_interface':
    path    => $config_file,
    section => 'agents',
    setting => 'incoming_interface',
    value   => $agents_incoming_interface
  }

  cassandra::opscenter::setting { 'agents incoming_port':
    path    => $config_file,
    section => 'agents',
    setting => 'incoming_port',
    value   => $agents_incoming_port
  }

  cassandra::opscenter::setting { 'agents install_throttle':
    path    => $config_file,
    section => 'agents',
    setting => 'install_throttle',
    value   => $agents_install_throttle
  }

  cassandra::opscenter::setting { 'agents not_seen_threshold':
    path    => $config_file,
    section => 'agents',
    setting => 'not_seen_threshold',
    value   => $agents_not_seen_threshold
  }

  cassandra::opscenter::setting { 'agents path_to_deb':
    path    => $config_file,
    section => 'agents',
    setting => 'path_to_deb',
    value   => $agents_path_to_deb
  }

  cassandra::opscenter::setting { 'agents path_to_find_java':
    path    => $config_file,
    section => 'agents',
    setting => 'path_to_find_java',
    value   => $agents_path_to_find_java
  }

  cassandra::opscenter::setting { 'agents path_to_installscript':
    path    => $config_file,
    section => 'agents',
    setting => 'path_to_installscript',
    value   => $agents_path_to_installscript
  }

  cassandra::opscenter::setting { 'agents path_to_rpm':
    path    => $config_file,
    section => 'agents',
    setting => 'path_to_rpm',
    value   => $agents_path_to_rpm
  }

  cassandra::opscenter::setting { 'agents path_to_sudowrap':
    path    => $config_file,
    section => 'agents',
    setting => 'path_to_sudowrap',
    value   => $agents_path_to_sudowrap
  }

  cassandra::opscenter::setting { 'agents reported_interface':
    path    => $config_file,
    section => 'agents',
    setting => 'reported_interface',
    value   => $agents_reported_interface
  }

  cassandra::opscenter::setting { 'agents runs_sudo':
    path    => $config_file,
    section => 'agents',
    setting => 'runs_sudo',
    value   => $agents_runs_sudo
  }

  cassandra::opscenter::setting { 'agents scp_executable':
    path    => $config_file,
    section => 'agents',
    setting => 'scp_executable',
    value   => $agents_scp_executable
  }

  cassandra::opscenter::setting { 'agents ssh_executable':
    path    => $config_file,
    section => 'agents',
    setting => 'ssh_executable',
    value   => $agents_ssh_executable
  }

  cassandra::opscenter::setting { 'agents ssh_keygen_executable':
    path    => $config_file,
    section => 'agents',
    setting => 'ssh_keygen_executable',
    value   => $agents_ssh_keygen_executable
  }

  cassandra::opscenter::setting { 'agents ssh_keyscan_executable':
    path    => $config_file,
    section => 'agents',
    setting => 'ssh_keyscan_executable',
    value   => $agents_ssh_keyscan_executable
  }

  cassandra::opscenter::setting { 'agents ssh_port':
    path    => $config_file,
    section => 'agents',
    setting => 'ssh_port',
    value   => $agents_ssh_port
  }

  cassandra::opscenter::setting { 'agents ssh_sys_known_hosts_file':
    path    => $config_file,
    section => 'agents',
    setting => 'ssh_sys_known_hosts_file',
    value   => $agents_ssh_sys_known_hosts_file
  }

  cassandra::opscenter::setting { 'agents ssh_user_known_hosts_file':
    path    => $config_file,
    section => 'agents',
    setting => 'ssh_user_known_hosts_file',
    value   => $agents_ssh_user_known_hosts_file
  }

  cassandra::opscenter::setting { 'agents ssl_certfile':
    path    => $config_file,
    section => 'agents',
    setting => 'ssl_certfile',
    value   => $agents_ssl_certfile
  }

  cassandra::opscenter::setting { 'agents ssl_keyfile':
    path    => $config_file,
    section => 'agents',
    setting => 'ssl_keyfile',
    value   => $agents_ssl_keyfile
  }

  cassandra::opscenter::setting { 'agents tmp_dir':
    path    => $config_file,
    section => 'agents',
    setting => 'tmp_dir',
    value   => $agents_tmp_dir
  }

  cassandra::opscenter::setting { 'agents use_ssl':
    path    => $config_file,
    section => 'agents',
    setting => 'use_ssl',
    value   => $agents_use_ssl
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

  cassandra::opscenter::setting { 'authentication authentication_method':
    path    => $config_file,
    section => 'authentication',
    setting => 'authentication_method',
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

  cassandra::opscenter::setting { 'cloud accepted_certs':
    path    => $config_file,
    section => 'cloud',
    setting => 'accepted_certs',
    value   => $cloud_accepted_certs
  }

  cassandra::opscenter::setting { 'clusters add_cluster_timeout':
    path    => $config_file,
    section => 'clusters',
    setting => 'add_cluster_timeout',
    value   => $clusters_add_cluster_timeout
  }

  cassandra::opscenter::setting { 'clusters startup_sleep':
    path    => $config_file,
    section => 'clusters',
    setting => 'startup_sleep',
    value   => $clusters_startup_sleep
  }

  cassandra::opscenter::setting { 'definitions auto_update':
    path    => $config_file,
    section => 'definitions',
    setting => 'auto_update',
    value   => $definitions_auto_update
  }

  cassandra::opscenter::setting { 'definitions definitions_dir':
    path    => $config_file,
    section => 'definitions',
    setting => 'definitions_dir',
    value   => $definitions_definitions_dir
  }

  cassandra::opscenter::setting { 'definitions download_filename':
    path    => $config_file,
    section => 'definitions',
    setting => 'download_filename',
    value   => $definitions_download_filename
  }

  cassandra::opscenter::setting { 'definitions download_host':
    path    => $config_file,
    section => 'definitions',
    setting => 'download_host',
    value   => $definitions_download_host
  }

  cassandra::opscenter::setting { 'definitions download_port':
    path    => $config_file,
    section => 'definitions',
    setting => 'download_port',
    value   => $definitions_download_port
  }

  cassandra::opscenter::setting { 'definitions hash_filename':
    path    => $config_file,
    section => 'definitions',
    setting => 'hash_filename',
    value   => $definitions_hash_filename
  }

  cassandra::opscenter::setting { 'definitions sleep':
    path    => $config_file,
    section => 'definitions',
    setting => 'sleep',
    value   => $definitions_sleep
  }

  cassandra::opscenter::setting { 'definitions ssl_certfile':
    path    => $config_file,
    section => 'definitions',
    setting => 'ssl_certfile',
    value   => $definitions_ssl_certfile
  }

  cassandra::opscenter::setting { 'definitions use_ssl':
    path    => $config_file,
    section => 'definitions',
    setting => 'use_ssl',
    value   => $definitions_use_ssl
  }

  cassandra::opscenter::setting { 'failover failover_configuration_directory':
    path    => $config_file,
    section => 'failover',
    setting => 'failover_configuration_directory',
    value   => $failover_configuration_directory
  }

  cassandra::opscenter::setting { 'failover heartbeat_fail_window':
    path    => $config_file,
    section => 'failover',
    setting => 'heartbeat_fail_window',
    value   => $failover_heartbeat_fail_window
  }

  cassandra::opscenter::setting { 'failover heartbeat_period':
    path    => $config_file,
    section => 'failover',
    setting => 'heartbeat_period',
    value   => $failover_heartbeat_period
  }

  cassandra::opscenter::setting { 'failover heartbeat_reply_period':
    path    => $config_file,
    section => 'failover',
    setting => 'heartbeat_reply_period',
    value   => $failover_heartbeat_reply_period
  }

  cassandra::opscenter::setting { 'hadoop base_job_tracker_proxy_port':
    path    => $config_file,
    section => 'hadoop',
    setting => 'base_job_tracker_proxy_port',
    value   => $hadoop_base_job_tracker_proxy_port
  }

  cassandra::opscenter::setting { 'ldap admin_group_name':
    path    => $config_file,
    section => 'ldap',
    setting => 'admin_group_name',
    value   => $ldap_admin_group_name
  }

  cassandra::opscenter::setting { 'ldap connection_timeout':
    path    => $config_file,
    section => 'ldap',
    setting => 'connection_timeout',
    value   => $ldap_connection_timeout
  }

  cassandra::opscenter::setting { 'ldap debug_ssl':
    path    => $config_file,
    section => 'ldap',
    setting => 'debug_ssl',
    value   => $ldap_debug_ssl
  }

  cassandra::opscenter::setting { 'ldap group_name_attribute':
    path    => $config_file,
    section => 'ldap',
    setting => 'group_name_attribute',
    value   => $ldap_group_name_attribute
  }

  cassandra::opscenter::setting { 'ldap group_search_base':
    path    => $config_file,
    section => 'ldap',
    setting => 'group_search_base',
    value   => $ldap_group_search_base
  }

  cassandra::opscenter::setting { 'ldap group_search_filter':
    path    => $config_file,
    section => 'ldap',
    setting => 'group_search_filter',
    value   => $ldap_group_search_filter
  }

  cassandra::opscenter::setting { 'ldap group_search_type':
    path    => $config_file,
    section => 'ldap',
    setting => 'group_search_type',
    value   => $ldap_group_search_type
  }

  cassandra::opscenter::setting { 'ldap ldap_security':
    path    => $config_file,
    section => 'ldap',
    setting => 'ldap_security',
    value   => $ldap_ldap_security
  }

  cassandra::opscenter::setting { 'ldap opt_referrals':
    path    => $config_file,
    section => 'ldap',
    setting => 'opt_referrals',
    value   => $ldap_opt_referrals
  }

  cassandra::opscenter::setting { 'ldap protocol_version':
    path    => $config_file,
    section => 'ldap',
    setting => 'protocol_version',
    value   => $ldap_protocol_version
  }

  cassandra::opscenter::setting { 'ldap search_dn':
    path    => $config_file,
    section => 'ldap',
    setting => 'search_dn',
    value   => $ldap_search_dn
  }

  cassandra::opscenter::setting { 'ldap search_password':
    path    => $config_file,
    section => 'ldap',
    setting => 'search_password',
    value   => $ldap_search_password
  }

  cassandra::opscenter::setting { 'ldap server_host':
    path    => $config_file,
    section => 'ldap',
    setting => 'server_host',
    value   => $ldap_server_host
  }

  cassandra::opscenter::setting { 'ldap server_port':
    path    => $config_file,
    section => 'ldap',
    setting => 'server_port',
    value   => $ldap_server_port
  }

  cassandra::opscenter::setting { 'ldap ssl_cacert':
    path    => $config_file,
    section => 'ldap',
    setting => 'ssl_cacert',
    value   => $ldap_ssl_cacert
  }

  cassandra::opscenter::setting { 'ldap ssl_cert':
    path    => $config_file,
    section => 'ldap',
    setting => 'ssl_cert',
    value   => $ldap_ssl_cert
  }

  cassandra::opscenter::setting { 'ldap ssl_key':
    path    => $config_file,
    section => 'ldap',
    setting => 'ssl_key',
    value   => $ldap_ssl_key
  }

  cassandra::opscenter::setting { 'ldap tls_demand':
    path    => $config_file,
    section => 'ldap',
    setting => 'tls_demand',
    value   => $ldap_tls_demand
  }

  cassandra::opscenter::setting { 'ldap tls_reqcert':
    path    => $config_file,
    section => 'ldap',
    setting => 'tls_reqcert',
    value   => $ldap_tls_reqcert
  }

  cassandra::opscenter::setting { 'ldap uri_scheme':
    path    => $config_file,
    section => 'ldap',
    setting => 'uri_scheme',
    value   => $ldap_uri_scheme
  }

  cassandra::opscenter::setting { 'ldap user_memberof_attribute':
    path    => $config_file,
    section => 'ldap',
    setting => 'user_memberof_attribute',
    value   => $ldap_user_memberof_attribute
  }

  cassandra::opscenter::setting { 'ldap user_search_base':
    path    => $config_file,
    section => 'ldap',
    setting => 'user_search_base',
    value   => $ldap_user_search_base
  }

  cassandra::opscenter::setting { 'ldap user_search_filter':
    path    => $config_file,
    section => 'ldap',
    setting => 'user_search_filter',
    value   => $ldap_user_search_filter
  }

  cassandra::opscenter::setting { 'logging level':
    path    => $config_file,
    section => 'logging',
    setting => 'level',
    value   => $logging_level
  }

  cassandra::opscenter::setting { 'logging log_length':
    path    => $config_file,
    section => 'logging',
    setting => 'log_length',
    value   => $logging_log_length
  }

  cassandra::opscenter::setting { 'logging log_path':
    path    => $config_file,
    section => 'logging',
    setting => 'log_path',
    value   => $logging_log_path
  }

  cassandra::opscenter::setting { 'logging max_rotate':
    path    => $config_file,
    section => 'logging',
    setting => 'max_rotate',
    value   => $logging_max_rotate
  }

  cassandra::opscenter::setting { 'logging resource_usage_interval':
    path    => $config_file,
    section => 'logging',
    setting => 'resource_usage_interval',
    value   => $logging_resource_usage_interval
  }

  cassandra::opscenter::setting { 'provisioning agent_install_timeout':
    path    => $config_file,
    section => 'provisioning',
    setting => 'agent_install_timeout',
    value   => $provisioning_agent_install_timeout
  }

  cassandra::opscenter::setting { 'provisioning keyspace_timeout':
    path    => $config_file,
    section => 'provisioning',
    setting => 'keyspace_timeout',
    value   => $provisioning_keyspace_timeout
  }

  cassandra::opscenter::setting { 'provisioning private_key_dir':
    path    => $config_file,
    section => 'provisioning',
    setting => 'private_key_dir',
    value   => $provisioning_private_key_dir
  }

  cassandra::opscenter::setting { 'repair_service alert_on_repair_failure':
    path    => $config_file,
    section => 'repair_service',
    setting => 'alert_on_repair_failure',
    value   => $repair_service_alert_on_repair_failure
  }

  cassandra::opscenter::setting { 'repair_service cluster_stabilization_period':
    path    => $config_file,
    section => 'repair_service',
    setting => 'cluster_stabilization_period',
    value   => $repair_service_cluster_stabilization_period
  }

  cassandra::opscenter::setting { 'repair_service error_logging_window':
    path    => $config_file,
    section => 'repair_service',
    setting => 'error_logging_window',
    value   => $repair_service_error_logging_window
  }

  cassandra::opscenter::setting { 'repair_service incremental_err_alert_threshold':
    path    => $config_file,
    section => 'repair_service',
    setting => 'incremental_err_alert_threshold',
    value   => $repair_service_incremental_err_alert_threshold
  }

  cassandra::opscenter::setting { 'repair_service incremental_range_repair':
    path    => $config_file,
    section => 'repair_service',
    setting => 'incremental_range_repair',
    value   => $repair_service_incremental_range_repair
  }

  cassandra::opscenter::setting { 'repair_service incremental_repair_tables':
    path    => $config_file,
    section => 'repair_service',
    setting => 'incremental_repair_tables',
    value   => $repair_service_incremental_repair_tables
  }

  cassandra::opscenter::setting { 'repair_service ks_update_period':
    path    => $config_file,
    section => 'repair_service',
    setting => 'ks_update_period',
    value   => $repair_service_ks_update_period
  }

  cassandra::opscenter::setting { 'repair_service log_directory':
    path    => $config_file,
    section => 'repair_service',
    setting => 'log_directory',
    value   => $repair_service_log_directory
  }

  cassandra::opscenter::setting { 'repair_service log_length':
    path    => $config_file,
    section => 'repair_service',
    setting => 'log_length',
    value   => $repair_service_log_length
  }

  cassandra::opscenter::setting { 'repair_service max_err_threshold':
    path    => $config_file,
    section => 'repair_service',
    setting => 'max_err_threshold',
    value   => $repair_service_max_err_threshold
  }

  cassandra::opscenter::setting { 'repair_service max_parallel_repairs':
    path    => $config_file,
    section => 'repair_service',
    setting => 'max_parallel_repairs',
    value   => $repair_service_max_parallel_repairs
  }

  cassandra::opscenter::setting { 'repair_service max_pending_repairs':
    path    => $config_file,
    section => 'repair_service',
    setting => 'max_pending_repairs',
    value   => $repair_service_max_pending_repairs
  }

  cassandra::opscenter::setting { 'repair_service max_rotate':
    path    => $config_file,
    section => 'repair_service',
    setting => 'max_rotate',
    value   => $repair_service_max_rotate
  }

  cassandra::opscenter::setting { 'repair_service min_repair_time':
    path    => $config_file,
    section => 'repair_service',
    setting => 'min_repair_time',
    value   => $repair_service_min_repair_time
  }

  cassandra::opscenter::setting { 'repair_service min_throughput':
    path    => $config_file,
    section => 'repair_service',
    setting => 'min_throughput',
    value   => $repair_service_min_throughput
  }

  cassandra::opscenter::setting { 'repair_service num_recent_throughputs':
    path    => $config_file,
    section => 'repair_service',
    setting => 'num_recent_throughputs',
    value   => $repair_service_num_recent_throughputs
  }

  cassandra::opscenter::setting { 'repair_service persist_directory':
    path    => $config_file,
    section => 'repair_service',
    setting => 'persist_directory',
    value   => $repair_service_persist_directory
  }

  cassandra::opscenter::setting { 'repair_service persist_period':
    path    => $config_file,
    section => 'repair_service',
    setting => 'persist_period',
    value   => $repair_service_persist_period
  }

  cassandra::opscenter::setting { 'repair_service restart_period':
    path    => $config_file,
    section => 'repair_service',
    setting => 'restart_period',
    value   => $repair_service_restart_period
  }

  cassandra::opscenter::setting { 'repair_service single_repair_timeout':
    path    => $config_file,
    section => 'repair_service',
    setting => 'single_repair_timeout',
    value   => $repair_service_single_repair_timeout
  }

  cassandra::opscenter::setting { 'repair_service single_task_err_threshold':
    path    => $config_file,
    section => 'repair_service',
    setting => 'single_task_err_threshold',
    value   => $repair_service_single_task_err_threshold
  }

  cassandra::opscenter::setting { 'repair_service snapshot_override':
    path    => $config_file,
    section => 'repair_service',
    setting => 'snapshot_override',
    value   => $repair_service_snapshot_override
  }

  cassandra::opscenter::setting { 'request_tracker queue_size':
    path    => $config_file,
    section => 'request_tracker',
    setting => 'queue_size',
    value   => $request_tracker_queue_size
  }

  cassandra::opscenter::setting { 'security config_encryption_active':
    path    => $config_file,
    section => 'security',
    setting => 'config_encryption_active',
    value   => $security_config_encryption_active
  }

  cassandra::opscenter::setting { 'security config_encryption_key_name':
    path    => $config_file,
    section => 'security',
    setting => 'config_encryption_key_name',
    value   => $security_config_encryption_key_name
  }

  cassandra::opscenter::setting { 'security config_encryption_key_path':
    path    => $config_file,
    section => 'security',
    setting => 'config_encryption_key_path',
    value   => $security_config_encryption_key_path
  }

  cassandra::opscenter::setting { 'spark base_master_proxy_port':
    path    => $config_file,
    section => 'spark',
    setting => 'base_master_proxy_port',
    value   => $spark_base_master_proxy_port
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

  cassandra::opscenter::setting { 'ui default_api_timeout':
    path    => $config_file,
    section => 'ui',
    setting => 'default_api_timeout',
    value   => $ui_default_api_timeout
  }

  cassandra::opscenter::setting { 'ui max_metrics_requests':
    path    => $config_file,
    section => 'ui',
    setting => 'max_metrics_requests',
    value   => $ui_max_metrics_requests
  }

  cassandra::opscenter::setting { 'ui node_detail_refresh_delay':
    path    => $config_file,
    section => 'ui',
    setting => 'node_detail_refresh_delay',
    value   => $ui_node_detail_refresh_delay
  }

  cassandra::opscenter::setting { 'ui storagemap_ttl':
    path    => $config_file,
    section => 'ui',
    setting => 'storagemap_ttl',
    value   => $ui_storagemap_ttl
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
