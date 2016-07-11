class pacemaker::new (
  $firewall_ipv6_manage     = $::pacemaker::new::params::firewall_ipv6_manage,
  $firewall_corosync_manage = $::pacemaker::new::params::firewall_corosync_manage,
  $firewall_corosync_ensure = $::pacemaker::new::params::firewall_corosync_ensure,
  $firewall_corosync_dport  = $::pacemaker::new::params::firewall_corosync_dport,
  $firewall_corosync_proto  = $::pacemaker::new::params::firewall_corosync_proto,
  $firewall_corosync_action = $::pacemaker::new::params::firewall_corosync_action,
  $firewall_pcsd_manage     = $::pacemaker::new::params::firewall_pcsd_manage,
  $firewall_pcsd_ensure     = $::pacemaker::new::params::firewall_pcsd_ensure,
  $firewall_pcsd_dport      = $::pacemaker::new::params::firewall_pcsd_dport,
  $firewall_pcsd_action     = $::pacemaker::new::params::firewall_pcsd_action,

  $package_manage   = $::pacemaker::new::params::package_manage,
  $package_list     = $::pacemaker::new::params::package_list,
  $package_ensure   = $::pacemaker::new::params::package_ensure,
  $package_provider = $::pacemaker::new::params::package_provider,

  $pcsd_mode            = $::pacemaker::new::params::pcsd_mode,
  $cluster_nodes        = $::pacemaker::new::params::cluster_nodes,
  $cluster_rrp_nodes    = $::pacemaker::new::params::cluster_rrp_nodes,
  $cluster_name         = $::pacemaker::new::params::cluster_name,
  $cluster_auth_key     = $::pacemaker::new::params::cluster_auth_key,
  $cluster_auth_enabled = $::pacemaker::new::params::cluster_auth_enabled,
  $cluster_setup        = $::pacemaker::new::params::cluster_setup,
  $cluster_options      = $::pacemaker::new::params::cluster_options,
  $cluster_user         = $::pacemaker::new::params::cluster_user,
  $cluster_group        = $::pacemaker::new::params::cluster_group,
  $cluster_password     = $::pacemaker::new::params::cluster_password,
  $pcs_bin_path         = $::pacemaker::new::params::pcs_bin_path,
  $cluster_config_path  = $::pacemaker::new::params::cluster_config_path,
  $cluster_interfaces   = $::pacemaker::new::params::cluster_interfaces,
  $cluster_log_subsys   = $::pacemaker::new::params::cluster_log_subsys,
  $plugin_version       = $::pacemaker::new::params::plugin_version,
  $log_file_path        = $::pacemaker::new::params::log_file_path,

  $pcsd_manage        = $::pacemaker::new::params::pcsd_manage,
  $pcsd_enable        = $::pacemaker::new::params::pcsd_enable,
  $pcsd_service       = $::pacemaker::new::params::pcsd_service,
  $pcsd_provider      = $::pacemaker::new::params::pcsd_provider,
  $corosync_manage    = $::pacemaker::new::params::corosync_manage,
  $corosync_enable    = $::pacemaker::new::params::corosync_enable,
  $corosync_service   = $::pacemaker::new::params::corosync_service,
  $corosync_provider  = $::pacemaker::new::params::corosync_provider,
  $pacemaker_manage   = $::pacemaker::new::params::pacemaker_manage,
  $pacemaker_enable   = $::pacemaker::new::params::pacemaker_enable,
  $pacemaker_service  = $::pacemaker::new::params::pacemaker_service,
  $pacemaker_provider = $::pacemaker::new::params::pacemaker_provider,
) inherits ::pacemaker::new::params {

  class { '::pacemaker::new::firewall' :
    firewall_ipv6_manage     => $firewall_ipv6_manage,
    firewall_corosync_manage => $firewall_corosync_manage,
    firewall_corosync_ensure => $firewall_corosync_ensure,
    firewall_corosync_dport  => $firewall_corosync_dport,
    firewall_corosync_proto  => $firewall_corosync_proto,
    firewall_corosync_action => $firewall_corosync_action,
    firewall_pcsd_manage     => $firewall_pcsd_manage,
    firewall_pcsd_ensure     => $firewall_pcsd_ensure,
    firewall_pcsd_dport      => $firewall_pcsd_dport,
    firewall_pcsd_action     => $firewall_pcsd_action,
  }

  class { '::pacemaker::new::install' :
    package_manage   => $package_manage,
    package_list     => $package_list,
    package_ensure   => $package_ensure,
    package_provider => $package_provider,
  }

  class { '::pacemaker::new::setup' :
    pcsd_mode           => $pcsd_mode,
    # pcsd only
    cluster_nodes       => $cluster_nodes,
    cluster_rrp_nodes   => $cluster_rrp_nodes,
    cluster_name        => $cluster_name,
    cluster_auth_key    => $cluster_auth_key,
    cluster_setup       => $cluster_setup,
    cluster_options     => $cluster_options,
    cluster_user        => $cluster_user,
    cluster_password    => $cluster_password,
    pcs_bin_path        => $pcs_bin_path,
    # config only
    cluster_config_path => $cluster_config_path,
    cluster_interfaces  => $cluster_interfaces,
    cluster_log_subsys  => $cluster_log_subsys,
    plugin_version      => $plugin_version,
    log_file_path       => $log_file_path,
  }

  class { '::pacemaker::new::service' :
    pcsd_manage        => $pcsd_manage,
    pcsd_enable        => $pcsd_enable,
    pcsd_service       => $pcsd_service,
    pcsd_provider      => $pcsd_provider,
    corosync_manage    => $corosync_manage,
    corosync_enable    => $corosync_enable,
    corosync_service   => $corosync_service,
    corosync_provider  => $corosync_provider,
    pacemaker_manage   => $pacemaker_manage,
    pacemaker_enable   => $pacemaker_enable,
    pacemaker_service  => $pacemaker_service,
    pacemaker_provider => $pacemaker_provider,
  }

  pacemaker::contain { 'pacemaker::new::firewall': }
  pacemaker::contain { 'pacemaker::new::install': }
  pacemaker::contain { 'pacemaker::new::setup': }
  pacemaker::contain { 'pacemaker::new::service': }

  Class['::pacemaker::new::firewall'] ->
  Class['::pacemaker::new::install']

  Class['::pacemaker::new::install'] ->
  Class['::pacemaker::new::service']

  Class['::pacemaker::new::install'] ->
  Class['::pacemaker::new::setup']

}
