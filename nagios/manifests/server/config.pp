# Nagios server configuration
class nagios::server::config(
  $admin_group,
  $admin_name,
  $admin_password,
  $admin_user,
  $openstack_adm_passwd,
  $openstack_controller,
) {

  class { 'nagios::server::base':
    admin_password => $admin_password,
    admin_name     => $admin_name,
    admin_user     => $admin_user,
    admin_group    => $admin_group,
    require        => Package['nagios'],
  }

  class { 'nagios::server::nrpe':
    require => Class['nagios::server::base'],
    before  => Service['nagios'],
  }

  class { 'nagios::server::openstack':
    admin_user           => $admin_user,
    admin_group          => $admin_group,
    openstack_adm_passwd => openstack_adm_passwd,
    openstack_controller => openstack_controller,
    require => Class['nagios::server::base'],
    before  => Service['nagios'],
  }
}
