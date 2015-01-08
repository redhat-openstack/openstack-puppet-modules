# == Class opendaylight::config
#
# This class is called from opendaylight for service config.
#
class opendaylight::config {
  # TODO: Create user/group
  file { '/etc/profile.d/opendaylight.sh':
    mode    => '0644',
    content => 'PATH=$PATH:/opt/opendaylight/bin',
  }
}
