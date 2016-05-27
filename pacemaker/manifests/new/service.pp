# == Class: pacemaker::new::service
#
# Manages the Corosync, Pacemaker and Pcsd services
#
class pacemaker::new::service (
  $pcsd_manage        = $::pacemaker::new::params::pcsd_enable,
  $pcsd_enable        = $::pacemaker::new::params::pcsd_enable,
  $pcsd_service       = $::pacemaker::new::params::pcsd_service,
  $pcsd_provider      = $::pacemaker::new::params::pcsd_provider,
  
  $corosync_manage    = $::pacemaker::new::params::corosync_enable,
  $corosync_enable    = $::pacemaker::new::params::corosync_enable,
  $corosync_service   = $::pacemaker::new::params::corosync_service,
  $corosync_provider  = $::pacemaker::new::params::corosync_provider,
  
  $pacemaker_manage   = $::pacemaker::new::params::pacemaker_enable,
  $pacemaker_enable   = $::pacemaker::new::params::pacemaker_enable,
  $pacemaker_service  = $::pacemaker::new::params::pacemaker_service,
  $pacemaker_provider = $::pacemaker::new::params::pacemaker_provider,
) inherits ::pacemaker::new::params {
  validate_bool($pcsd_manage)
  validate_bool($pcsd_enable)
  validate_string($pcsd_service)

  validate_bool($corosync_manage)
  validate_bool($corosync_enable)
  validate_string($corosync_service)

  validate_bool($pacemaker_manage)
  validate_bool($pacemaker_enable)
  validate_string($pacemaker_service)

  if $pcsd_enable {
    $pcsd_ensure = 'running'
  } else {
    $pcsd_ensure = 'stopped'
  }

  if $corosync_enable {
    $corosync_ensure = 'running'
  } else {
    $corosync_ensure = 'stopped'
  }

  if $pacemaker_enable {
    $pacemaker_ensure = 'running'
  } else {
    $pacemaker_ensure = 'stopped'
  }

  if $pcsd_manage {
    service { 'pcsd' :
      ensure   => $pcsd_ensure,
      enable   => $pcsd_enable,
      name     => $pcsd_service,
      provider => $pcsd_provider,
    }
  }

  if $corosync_manage {
    service { 'corosync' :
      ensure   => $corosync_ensure,
      enable   => $corosync_enable,
      name     => $corosync_service,
      provider => $corosync_provider,
      tag      => 'cluster-service',
    }
  }

  if $pacemaker_manage {
    service { 'pacemaker' :
      ensure   => $pacemaker_ensure,
      enable   => $pacemaker_enable,
      name     => $pacemaker_service,
      provider => $pacemaker_provider,
      tag      => 'cluster-service',
    }
  }

  Service <| title == 'corosync' |> ->
  Service <| title == 'pacemaker' |>
  
}
