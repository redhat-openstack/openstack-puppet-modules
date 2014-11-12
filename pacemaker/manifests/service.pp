class pacemaker::service (
  $ensure     = running,
  $hasstatus  = true,
  $hasrestart = true,
  $enable     = true,
) {
  include pacemaker::params

  service { $pacemaker::params::service_name:
    ensure     => $ensure,
    hasstatus  => $hasstatus,
    hasrestart => $hasrestart,
    enable     => $enable,
    require    => Class['::pacemaker::install'],
  }
}
