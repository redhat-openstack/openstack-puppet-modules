# == Class: pacemaker::new::setup::config
#
# Set the cluster up by directly generating
# the Corosync configuration file.
#
# [*cluster_nodes*]
#   The cluster nodes structure.
#   Can be provided in serveral formats.
#
# [*cluster_rrp_nodes*]
#   Same as *cluster_nodes* and will override thir value.
#
# [*cluster_name*]
#   The name attribute of the cluster.
#   Default: clustername
#
# [*cluster_auth_enabled*]
#   Does this cluster have a Corosync auth key?
#   Default: false
#
# [*cluster_setup*]
#   Should this cluster be set up?
#   Default: true
#
# [*cluster_options*]
#   A hash of additional cluster options.
#   Totem section:
#   * version
#   * nodeid
#   * clear_node_high_bit
#   * secauth
#   * crypto_cipher
#   * crypto_hash
#   * rrp_mode
#   * netmtu
#   * threads
#   * vsftype
#   * transport
#   * token
#   * token_retransmit
#   * hold
#   * token_retransmits_before_loss_const
#   * join
#   * send_join
#   * consensus
#   * merge
#   * downcheck
#   * fail_recv_const
#   * seqno_unchanged_const
#   * heartbeat_failures_allowed
#   * max_network_delay
#   * window_size
#   * max_messages
#   * miss_count_const
#   * rrp_problem_count_timeout
#   * rrp_problem_count_threshold
#   * rrp_problem_count_mcast_threshold
#   * rrp_token_expired_timeout
#   * rrp_autorecovery_check_timeout
#   Logging section:
#   * timestamp
#   * fileline
#   * function_name
#   * to_stderr
#   * to_logfile
#   * to_syslog
#   * logfile
#   * logfile_priority
#   * syslog_facility
#   * syslog_priority
#   * debug
#   * tags
#   * subsys
#   Quorum section:
#   * provider
#   * two_node
#   * wait_for_all
#   * last_man_standing
#   * last_man_standing_window
#   * auto_tie_breaker
#   * auto_tie_breaker_node
#   * allow_downscale
#   * expected_votes
#   * expected_votes_tracking
#   * votes
#
# [*cluster_config_path*]
#   Path to the cluster configuration file.
#   Default: /etc/corosync/corosync.conf
#
# [*cluster_interfaces*]
#   An array of hashes or a single hash with the cluster
#   interface properties. This should be provided if the
#   UDP multicast communications are being used to set
#   the addresses:
#   * ringnumber
#   * bindnetaddr
#   * nodeid
#   * broadcast
#   * mcastaddr
#   * mcastport
#   * ttl
#
# [*cluster_log_subsys*]
#   An array of hashes or a single hash with the logger
#   subsystem options. They will be added to the logging
#   section and have the same parameters as the logging section
#   itself with *subsys* name being mandatory.
#
# [*log_file_path*]
#   Path to the cluster log file.
#
class pacemaker::new::setup::config (
  $cluster_nodes        = $::pacemaker::new::params::cluster_nodes,
  $cluster_rrp_nodes    = $::pacemaker::new::params::cluster_rrp_nodes,
  $cluster_name         = $::pacemaker::new::params::cluster_name,
  $cluster_auth_enabled = $::pacemaker::new::params::cluster_auth_enabled,
  $cluster_setup        = $::pacemaker::new::params::cluster_setup,
  $cluster_options      = $::pacemaker::new::params::cluster_options,
  $cluster_config_path  = $::pacemaker::new::params::cluster_config_path,
  $cluster_interfaces   = $::pacemaker::new::params::cluster_interfaces,
  $cluster_log_subsys   = $::pacemaker::new::params::cluster_log_subsys,
  $log_file_path        = $::pacemaker::new::params::log_file_path,
) inherits ::pacemaker::new::params {
  validate_absolute_path($log_file_path)
  validate_absolute_path($cluster_config_path)
  validate_hash($cluster_options)
  validate_string($cluster_name)
  validate_bool($cluster_auth_enabled)
  validate_bool($cluster_setup)

  if $cluster_setup {
    $cluster_nodes_real = pick($cluster_rrp_nodes, $cluster_nodes, [])
    $cluster_nodes_data = pacemaker_cluster_nodes($cluster_nodes_real, 'hash')

    file { 'corosync-config' :
      ensure  => 'present',
      path    => '/etc/corosync/corosync.conf',
      content => template('pacemaker/corosync.conf.erb'),
    }

    File['corosync-config'] ~>
    Service <| tag == 'cluster-service' |>
  }

  pacemaker_online { 'setup' :}

  Service <| tag == 'cluster-service' |> ->
  Pacemaker_online['setup']

}
