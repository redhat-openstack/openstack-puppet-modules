# == Class opendaylight::service
#
# Starts the OpenDaylight systemd service.
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
