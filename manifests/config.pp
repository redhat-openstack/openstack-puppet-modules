# == Class opendaylight::config
#
# This class handles ODL config changes.
# It's called from the opendaylight class.
#
# === Parameters
# [*odl_rest_port *]
#   Port for ODL northbound REST interface to listen on.
#
class opendaylight::config {
  # Configuration of Karaf features to install
  file { 'org.apache.karaf.features.cfg':
    ensure  => file,
    path    => '/opt/opendaylight/etc/org.apache.karaf.features.cfg',
    # Set user:group owners
    owner   => 'odl',
    group   => 'odl',
    # Use a template to populate the content
    content => template('opendaylight/org.apache.karaf.features.cfg.erb'),
  }

  # Configuration of ODL NB REST port to listen on
  file { 'tomcat-server.xml':
    ensure  => file,
    path    => '/opt/opendaylight/configuration/tomcat-server.xml',
    # Set user:group owners
    owner   => 'odl',
    group   => 'odl',
    # Use a template to populate the content
    content => template('opendaylight/tomcat-server.xml.erb'),
  }
}
