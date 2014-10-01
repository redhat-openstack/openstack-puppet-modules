class pacemaker::service (
  $ensure     = running,
  $hasstatus  = true,
  $hasrestart = true,
  $enable     = true,
) {
  include ::pacemaker::params

  if $::pacemaker::params::pcsd_mode {
    # only set up pcsd, not the other cluster services which have
    # very specific setup and when-to-start-up requirements
    # that are taken care of in corosync.pp
    service { 'pcsd':
      ensure     => $ensure,
      hasstatus  => $hasstatus,
      hasrestart => $hasrestart,
      enable     => $enable,
      require    => Class['::pacemaker::install'],
    }
  } else {
    service { $::pacemaker::params::service_name:
      ensure     => $ensure,
      hasstatus  => $hasstatus,
      hasrestart => $hasrestart,
      enable     => $enable,
      require    => Class['::pacemaker::install'],
    }
  }
}
