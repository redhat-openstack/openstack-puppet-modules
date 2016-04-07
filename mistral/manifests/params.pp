# == Class: mistral::params
#
# Parameters for puppet-mistral
#
class mistral::params {

  $client_package      = 'python-mistralclient'
  $db_sync_command     = 'mistral-db-manage --config-file=/etc/mistral/mistral.conf upgrade head'
  $db_populate_command = 'mistral-db-manage --config-file=/etc/mistral/mistral.conf populate'

  case $::osfamily {
    'RedHat': {
      $common_package_name        = 'openstack-mistral-common'
      $api_package_name           = 'openstack-mistral-api'
      $api_service_name           = 'openstack-mistral-api'
      $engine_package_name        = 'openstack-mistral-engine'
      $engine_service_name        = 'openstack-mistral-engine'
      $executor_package_name      = 'openstack-mistral-executor'
      $executor_service_name      = 'openstack-mistral-executor'
      $mistral_wsgi_script_path   = '/var/www/cgi-bin/mistral'
      $mistral_wsgi_script_source = '/usr/lib/python2.7/site-packages/mistral/api/wsgi.py'
      $pymysql_package_name       = undef
    }
    'Debian': {
      $common_package_name        = 'mistral'
      $api_package_name           = 'mistral-api'
      $api_service_name           = 'mistral-api'
      $engine_package_name        = 'mistral-engine'
      $engine_service_name        = 'mistral-engine'
      $executor_package_name      = 'mistral-executor'
      $executor_service_name      = 'mistral-executor'
      $mistral_wsgi_script_path   = '/usr/lib/cgi-bin/mistral'
      $mistral_wsgi_script_source = '/usr/share/mistral-common/wsgi.py'
      $pymysql_package_name       = 'python-pymysql'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem: \
      ${::operatingsystem}, module ${module_name} only support osfamily \
      RedHat and Debian")
    }
  }
}
