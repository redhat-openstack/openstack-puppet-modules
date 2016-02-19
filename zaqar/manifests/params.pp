# == Class: zaqar::params
#
# Parameters for puppet-zaqar
#
class zaqar::params {
  $client_package            = 'python-zaqarclient'
  case $::osfamily {
    'RedHat': {
      $package_name = 'openstack-zaqar'
      $service_name = 'openstack-zaqar'
    }
    'Debian': {
      $package_name = 'zaqar'
      $service_name = 'zaqar'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem: \
      ${::operatingsystem}, module ${module_name} only support osfamily \
      RedHat and Debian")
    }
  }
}
