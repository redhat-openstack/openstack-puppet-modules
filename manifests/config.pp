# == Class opendaylight::config
#
# This class is called from opendaylight for service config.
#
class opendaylight::config {
  # TODO: Confirm that this is a reasonable place to configure these
  $default_features = ['config', 'standard', 'region', 'package', 'kar', 'ssh', 'management']

  # TODO: Get extra features from user, add to default features
  $features = $default_features

  # This is very fragile, but I don't know of a better way to do it.
  # Updated ODL versions will break it, as will changes to the file upstream.
  file { 'org.apache.karaf.features.cfg':
    ensure  => file,
    path    => '/opt/etc/org.apache.karaf.features.cfg',
    content => template('opendaylight/org.apache.karaf.features.cfg.erb'),
  }
}
