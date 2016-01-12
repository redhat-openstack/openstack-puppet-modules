# Parameters for puppet-gnocchi
#
class gnocchi::params {

  case $::osfamily {
    'RedHat': {
      $sqlite_package_name        = undef
      $common_package_name        = 'openstack-gnocchi-common'
      $api_package_name           = 'openstack-gnocchi-api'
      $api_service_name           = 'openstack-gnocchi-api'
      $indexer_package_name       = 'openstack-gnocchi-indexer-sqlalchemy'
      $carbonara_package_name     = 'openstack-gnocchi-carbonara'
      $statsd_package_name        = 'openstack-gnocchi-statsd'
      $statsd_service_name        = 'openstack-gnocchi-statsd'
      $client_package_name        = 'python-gnocchiclient'
      $gnocchi_wsgi_script_path   = '/var/www/cgi-bin/gnocchi'
      $gnocchi_wsgi_script_source = '/usr/lib/python2.7/site-packages/gnocchi/rest/app.wsgi'
      $pymysql_package_name       = undef
    }
    'Debian': {
      $sqlite_package_name        = 'python-pysqlite2'
      $common_package_name        = 'gnocchi-common'
      $api_package_name           = 'gnocchi-api'
      $api_service_name           = 'gnocchi-api'
      $indexer_package_name       = 'gnocchi-indexer-sqlalchemy'
      $carbonara_package_name     = 'gnocchi-carbonara'
      $statsd_package_name        = 'gnocchi-statsd'
      $statsd_service_name        = 'gnocchi-statsd'
      $client_package_name        = 'python-gnocchiclient'
      $gnocchi_wsgi_script_path   = '/usr/lib/cgi-bin/gnocchi'
      $gnocchi_wsgi_script_source = '/usr/share/gnocchi-common/app.wsgi'
      $pymysql_package_name       = 'python-pymysql'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem")
    }

  } # Case $::osfamily
}
