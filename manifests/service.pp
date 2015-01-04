# == Class opendaylight::service
#
# This class is meant to be called from opendaylight.
# It ensure the service is running.
#
class opendaylight::service {

  service { $::opendaylight::service_name:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
