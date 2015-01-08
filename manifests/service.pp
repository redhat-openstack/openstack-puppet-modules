# == Class opendaylight::service
#
# This class is meant to be called from opendaylight.
# It ensure the service is running.
#
class opendaylight::service {
  # TODO: Actually make ODL into a service that works this way

  service { $::opendaylight::service_name:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
