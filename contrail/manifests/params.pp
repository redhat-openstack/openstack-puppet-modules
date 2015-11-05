# == Class: contrail::params
#
class contrail::params {

  $control_package_name = ['contrail-openstack-control']
  $config_package_name = ['contrail-openstack-config']
  $analytics_package_name = ['contrail-openstack-analytics']
  $webui_package_name = ['contrail-openstack-webui']
  $database_package_name = ['contrail-openstack-database']
  $vrouter_package_name = ['contrail-openstack-vrouter']

}
