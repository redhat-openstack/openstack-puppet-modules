# == Class opendaylight::config
#
# This class is called from opendaylight for service config.
#
class opendaylight::config (
   $odl_rest_port = $::opendaylight::params::odl_rest_port
) inherits ::opendaylight::params {
  # This is very fragile, but I don't know of a better way to do it.
  # Updated ODL versions will break it, as will changes to the file upstream.
  file { 'org.apache.karaf.features.cfg':
    ensure  => file,
    path    => '/opt/opendaylight-0.2.2/etc/org.apache.karaf.features.cfg',
    content => template('opendaylight/org.apache.karaf.features.cfg.erb'),
  }
  
  include stdlib
  $myline= "    <Connector port=\"${odl_rest_port}\" protocol=\"HTTP/1.1\""
  file_line { 'tomcatport':
    ensure => present,
    path => '/opt/opendaylight-0.2.2/configuration/tomcat-server.xml',
    line => $myline,
    match => '^\s*<Connector\s*port=\"[0-9]+\"\s*protocol=\"HTTP\/1.1\"$',
  }
}
