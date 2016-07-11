#
# Installs the aodh python library.
#
# == parameters
#  [*ensure*]
#    ensure state for pachage.
#
class aodh::client (
  $ensure = 'present'
) {

  include ::aodh::params

  package { 'python-aodhclient':
    ensure => $ensure,
    name   => $::aodh::params::client_package_name,
    tag    => 'openstack',
  }

}

