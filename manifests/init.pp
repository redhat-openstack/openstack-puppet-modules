# == Class: opendaylight
#
# OpenDaylight SDN Controller
#
# === Parameters
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#
class opendaylight (
  $package_name = $::opendaylight::params::package_name,
  $service_name = $::opendaylight::params::service_name,
) inherits ::opendaylight::params {

  # Validate OS
  case $::operatingsystem {
    centos, redhat: {
      if $::operatingsystemmajrelease != 7 {
        # RHEL/CentOS versions < 7 not supported as they lack systemd
        fail("Unsupported OS: ${::operatingsystem} ${::operatingsystemmajrelease}")
      }
    }
    fedora: {
      # TODO: Only need >= 15 for systemd if move to tarball or full yum repo
      if ! ($::operatingsystemmajrelease in [19, 20, 21]) {
        # Fedora versions < 19 can't be build on Copr, >21 don't exist
        fail("Unsupported OS: ${::operatingsystem} ${::operatingsystemmajrelease}")
      }
    }
    default: {
      fail("Unsupported OS: ${::operatingsystem}")
    }
  }

  class { '::opendaylight::install': } ->
  class { '::opendaylight::config': } ~>
  class { '::opendaylight::service': } ->
  Class['::opendaylight']
}
