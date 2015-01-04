# == Class opendaylight::install
#
# This class is called from opendaylight for install.
#
class opendaylight::install {

  package { $::opendaylight::package_name:
    ensure => present,
  }
}
