# == Class opendaylight::params
#
# This class is meant to be called from opendaylight.
# It sets variables according to platform.
#
class opendaylight::params {
  # Validate OS
  case $::operatingsystem {
    centos, redhat: {
      if $::lsbmajdistrelease != 7 {
        # RHEL/CentOS versions < 7 not supported as they lack systemd
        fail("Unsupported OS: ${::operatingsystem} ${::lsbmajdistrelease}")
      }
    }
    fedora: {
      # TODO: Only need >= 15 for systemd if move to tarball or full yum repo
      if ! ($::lsbmajdistrelease in [19, 20, 21]) {
        # Fedora versions < 19 can't be build on Copr, >21 don't exist
        fail("Unsupported OS: ${::operatingsystem} ${::lsbmajdistrelease}")
      }
    }
    default: {
      fail("Unsupported OS: ${::operatingsystem}")
    }
  }
  $package_name = 'opendaylight'
  $service_name = 'opendaylight'
}
