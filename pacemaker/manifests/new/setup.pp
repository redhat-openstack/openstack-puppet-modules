# == Class: pacemaker::new::setup
#
# Sets ups the cluster configuration
# either using the "pcsd" service or
# by creating the configuration file directy.
#
class pacemaker::new::setup (
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
) inherits ::pacemaker::new::params {
  if $::osfamily == 'Debian' {
    class { '::pacemaker::new::setup::debian' :
      plugin_version => $plugin_version,
    }
    pacemaker::contain { 'pacemaker::new::setup::debian': }
  }

  class { '::pacemaker::new::setup::auth_key' :
    cluster_auth_enabled => $cluster_auth_enabled,
    cluster_auth_key     => $cluster_auth_key,
    cluster_user         => $cluster_user,
    cluster_group        => $cluster_group,
  }
  pacemaker::contain { 'pacemaker::new::setup::auth_key': }

  if $pcsd_mode {
    class { '::pacemaker::new::setup::pcsd' :
      cluster_nodes     => $cluster_nodes,
      cluster_rrp_nodes => $cluster_rrp_nodes,
      cluster_name      => $cluster_name,
      cluster_setup     => $cluster_setup,
      cluster_options   => $cluster_options,
      cluster_user      => $cluster_user,
      cluster_group     => $cluster_group,
      cluster_password  => $cluster_password,
      pcs_bin_path      => $pcs_bin_path,
    }
    pacemaker::contain { 'pacemaker::new::setup::pcsd': }
  } else {
    class { '::pacemaker::new::setup::config' :
      cluster_nodes        => $cluster_nodes,
      cluster_rrp_nodes    => $cluster_rrp_nodes,
      cluster_name         => $cluster_name,
      cluster_auth_enabled => $cluster_auth_enabled,
      cluster_setup        => $cluster_setup,
      cluster_options      => $cluster_options,
      cluster_config_path  => $cluster_config_path,
      cluster_interfaces   => $cluster_interfaces,
      cluster_log_subsys   => $cluster_log_subsys,
      log_file_path        => $log_file_path,
    }
    pacemaker::contain { 'pacemaker::new::setup::config': }
  }
}
