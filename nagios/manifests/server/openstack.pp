# Openstack class for Nagios server
class nagios::server::openstack(
  $admin_group,
  $admin_user,
  $commands,
  $hostgroups = $nagios::params::hostgroups,
  $openstack_adm_passwd,
  $openstack_controller,
  $packages,
  $services,
) inherits nagios::params {

  File {
    owner => $admin_user,
    group => $admin_group,
  }

  file {'/etc/nagios/keystonerc_admin':
    ensure  => 'present',
    mode    => 0600,
    content => template('nagios/keystonerc_admin.erb'),
  }

  $file_defaults = {
    'ensure'  => present,
    'mode'    => '0755',
    'seltype' => 'nagios_unconfined_plugin_exec_t',
  }

  $command_defaults = {
    'ensure'  => present,
    'target' => '/etc/nagios/conf.d/commands.cfg',
  }

  $hostgroup_defaults = {
    'ensure'  => present,
    'target' => '/etc/nagios/conf.d/hostgroups.cfg',
  }

  $service_defaults = {
    'ensure'  => present,
    'target' => '/etc/nagios/conf.d/services.cfg',
  }

  # Cannot used Hiera for the files when content is a template
  # unless using another set of variables
  file {"/usr/lib64/nagios/plugins/ceilometer-list":
    content => template('nagios/ceilometer-list.erb')
  }
  file {"/usr/lib64/nagios/plugins/cinder-list":
    content => template('nagios/cinder-list.erb')
  }
  file {"/usr/lib64/nagios/plugins/glance-list":
    content => template('nagios/glance-list.erb')
  }
  file {"/usr/lib64/nagios/plugins/heat-list":
    content => template('nagios/heat-list.erb')
  }
  file {"/usr/lib64/nagios/plugins/keystone-user-list":
    content => template('nagios/keystone-user-list.erb')
  }
  file {"/usr/lib64/nagios/plugins/neutron-net-list":
    content => template('nagios/neutron-net-list.erb')
  }
  file {"/usr/lib64/nagios/plugins/neutron-network-check":
    content => template('nagios/neutron-network-check')
  }
  file {"/usr/lib64/nagios/plugins/swift-list":
    content => template('nagios/swift-list.erb')
  }
  file {"/usr/lib64/nagios/plugins/nova-list":
    content => template('nagios/nova-list.erb')
  }

  package {$packages:
    ensure => present
  }

  create_resources(nagios_command, $commands, $command_defaults)

  create_resources(nagios_hostgroup, $hostgroups, $hostgroup_defaults)

  $services_used = nagios_services_active($services)

  create_resources(nagios_service, $services_used, $service_defaults)

  Nagios_host {
    target => '/etc/nagios/conf.d/hosts.cfg'
  }

  if "${settings::storeconfigs_backend}" == 'puppetdb' {
    # Collect Opentsack hosts
    Nagios_host <<| |>>
  }
  else {
    create_resources(nagios_host, nagios_hosts_get(), { 'ensure' => present })
  }
}
