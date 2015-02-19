# Parameters for puppet-gnocchi
#
class gnocchi::params {

  case $::osfamily {
    'RedHat': {
      $api_package_name         = 'openstack-gnocchi-api'
      $api_service_name         = 'openstack-gnocchi-api'
    }
    'Debian': {
      $api_package_name         = 'gnocchi-api'
      $api_service_name         = 'gnocchi-api'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem")
    }

  } # Case $::osfamily
}
