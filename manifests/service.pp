# == Class opendaylight::service
#
# This class is meant to be called from opendaylight.
# It ensure the service is running.
#
class opendaylight::service {
  service { 'opendaylight':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    # TODO: Confirm this is actually supported by ODL service
    hasrestart => true,
  }
}
