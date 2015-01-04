# == Class opendaylight::params
#
# This class is meant to be called from opendaylight.
# It sets variables according to platform.
#
class opendaylight::params {
  case $::osfamily {
    'Debian': {
      $package_name = 'opendaylight'
      $service_name = 'opendaylight'
    }
    'RedHat', 'Amazon': {
      $package_name = 'opendaylight'
      $service_name = 'opendaylight'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
