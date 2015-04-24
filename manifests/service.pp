# == Class opendaylight::service
#
# Starts the OpenDaylight systemd or Upstart service.
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
