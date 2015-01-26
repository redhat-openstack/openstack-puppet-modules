# == Class opendaylight::config
#
# This class is called from opendaylight for service config.
#
class opendaylight::config {
  # This is very fragile, but I don't know of a better way to do it.
  # Updated ODL versions will break it, as will changes to the file upstream.
  file { 'org.apache.karaf.features.cfg':
    ensure  => file,
    path    => '/opt/opendaylight-0.2.1/etc/org.apache.karaf.features.cfg',
    content => template('opendaylight/org.apache.karaf.features.cfg.erb'),
  }
}
