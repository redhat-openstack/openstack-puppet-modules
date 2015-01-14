# == Class opendaylight::params
#
# This class is meant to be called from opendaylight.
# It sets variables according to platform.
#
class opendaylight::params {
  # Validate OS
  case $::operatingsystem {
    centos, redhat: {
      unless $::lsbmajdistrelease == 7 {
        fail('RHEL/CentOS versions < 7 not supported as they lack systemd')
      }
    }
    fedora: {
      # TODO: Only need >= 15 for systemd if move to tarball or full yum repo
      unless $::lsbmajdistrelease >= 19 {
        fail('Fedora versions < 19 not supported as not buildable on Copr')
      }
    }
    default: {
      fail("Unsupported OS: ${::operatingsystem}")
    }
  }
  $package_name = 'opendaylight'
  $service_name = 'opendaylight'
}
