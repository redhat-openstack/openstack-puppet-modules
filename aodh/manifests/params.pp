# Parameters for puppet-aodh
#
class aodh::params {

  $client_package_name = 'python-ceilometerclient'

  case $::osfamily {
    'RedHat': {
      $common_package_name     = 'openstack-aodh-common'
      $psycopg_package_name    = 'python-psycopg2'
      $sqlite_package_name     = undef
      $api_package_name        = 'openstack-aodh-api'
      $api_service_name        = 'openstack-aodh-api'
      $notifier_package_name   = 'openstack-aodh-notifier'
      $notifier_service_name   = 'openstack-aodh-notifier'
      $evaluator_package_name  = 'openstack-aodh-evaluator'
      $evaluator_service_name  = 'openstack-aodh-evaluator'
      $expirer_package_name    = 'openstack-aodh-expirer'
      $expirer_package_serice  = 'openstack-aodh-expirer'
      $listener_package_name   = 'openstack-aodh-listener'
      $listener_service_name   = 'openstack-aodh-listener'
      $pymongo_package_name    = 'python-pymongo'
      $aodh_wsgi_script_path   = '/var/www/cgi-bin/aodh'
      $aodh_wsgi_script_source = '/usr/lib/python2.7/site-packages/aodh/api/app.wsgi'
    }
    'Debian': {
      $common_package_name     = 'aodh-common'
      $psycopg_package_name    = 'python-psycopg2'
      $sqlite_package_name     = 'python-pysqlite2'
      $api_package_name        = 'aodh-api'
      $api_service_name        = 'aodh-api'
      $notifier_package_name   = 'aodh-notifier'
      $notifier_service_name   = 'aodh-notifier'
      $evaluator_package_name  = 'aodh-evaluator'
      $evaluator_service_name  = 'aodh-evaluator'
      $expirer_package_name    = 'aodh-expirer'
      $expirer_package_serice  = 'aodh-expirer'
      $listener_package_name   = 'aodh-listener'
      $listener_service_name   = 'aodh-listener'
      $pymongo_package_name    = 'python-pymongo'
      $aodh_wsgi_script_path   = '/usr/lib/cgi-bin/aodh'
      $aodh_wsgi_script_source = '/usr/share/aodh-common/app.wsgi'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem")
    }

  } # Case $::osfamily
}
