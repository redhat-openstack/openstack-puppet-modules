# Class for Nagios server
class nagios::server (
  $admin_group     = $nagios::params::admin_group,
  $admin_name      = $nagios::params::admin_name,
  $admin_password,
  $admin_user      = $nagios::params::admin_user,
  $openstack_adm_passwd,
  $openstack_controller,
  $server_packages = $nagios::params::server_packages,
) inherits nagios::params {

  Exec { timeout => 300 }

  File {
    owner => $nagios_user,
    group => $nagios_group,
  }

  package {$server_packages:
    ensure => present
  }

  class {'nagios::server::config':
    admin_group    => $admin_group,
    admin_name     => $admin_name,
    admin_password => $admin_password,
    admin_user     => $admin_user,
    openstack_adm_passwd => openstack_adm_passwd,
    openstack_controller => openstack_controller,
    require => Package['nagios'],
    notify  => Service['httpd'],
  }

  class {'apache':}
  class {'apache::mod::php':}
  class {'apache::mod::wsgi':}

  # To avoid apache module to purges files it doesn't know about:
  file {'/etc/httpd/conf.d/rootredirect.conf':}
  file {'/etc/httpd/conf.d/nagios.conf':}

  service {['nagios']:
    ensure    => running,
    enable    => true,
    hasstatus => true,
  }
}
