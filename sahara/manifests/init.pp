# == Class: sahara
#
#  Sahara base package & configuration
#
# === Parameters
#
# [*package_ensure*]
#   (Optional) Ensure state for package
#   Defaults to 'present'.
#
# [*manage_service*]
#   (optional) Whether the service should be managed by Puppet.
#   Defaults to true.
#
# [*enabled*]
#   (optional) Should the service be enabled.
#   Defaults to true.
#
# [*verbose*]
#   (Optional) Should the daemons log verbose messages
#   Defaults to 'false'.
#
# [*debug*]
#   (Optional) Should the daemons log debug messages
#   Defaults to 'false'.
#
# [*service_host*]
#   (Optional) Hostname for sahara to listen on
#   Defaults to '0.0.0.0'.
#
# [*service_port*]
#   (Optional) Port for sahara to listen on
#   Defaults to 8386.
#
# [*use_neutron*]
#   (Optional) Whether to use neutron
#   Defaults to 'false'.
#
# [*use_floating_ips*]
#   (Optional) Whether to use floating IPs to communicate with instances.
#   Defaults to 'true'.
#
# [*database_connection*]
#   (Optional) Non-sqllite database for sahara
#   Defaults to 'mysql://sahara:secrete@localhost:3306/sahara'.
#
# == keystone authentication options
#
# [*os_username*]
#   (Optional) Username for sahara credentials
#   Defaults to 'admin'.
#
# [*os_password*]
#   (Optional) Password for sahara credentials
#   Defaults to 'secrete'.
#
# [*os_tenant_name*]
#   (Optional) Tenant for os_username
#   Defaults to 'admin'.
#
# [*os_auth_url*]
#   (Optional) Public identity endpoint
#   Defaults to 'http://127.0.0.1:5000/v2.0/'.
#
# [*identity_url*]
#   (Optional) Admin identity endpoint
#   Defaults to 'http://127.0.0.1:35357/'.
#
class sahara(
  $manage_service      = true,
  $enabled             = true,
  $package_ensure      = 'present',
  $verbose             = false,
  $debug               = false,
  $service_host        = '0.0.0.0',
  $service_port        = 8386,
  $use_neutron         = false,
  $use_floating_ips    = true,
  $database_connection = 'mysql://sahara:secrete@localhost:3306/sahara',
  $os_username         = 'admin',
  $os_password         = 'secrete',
  $os_tenant_name      = 'admin',
  $os_auth_url         = 'http://127.0.0.1:5000/v2.0/',
  $identity_url        = 'http://127.0.0.1:35357/',
) {
  include sahara::params

  file { '/etc/sahara/':
    ensure  => directory,
    owner   => 'root',
    group   => 'sahara',
    mode    => '0750',
    require => Package['sahara'],
  }

  file { '/etc/sahara/sahara.conf':
    owner   => 'root',
    group   => 'sahara',
    mode    => '0640',
    require => File['/etc/sahara'],
  }

  package { 'sahara':
    ensure => $package_ensure,
    name   => $::sahara::params::package_name,
  }

  Package['sahara'] -> Sahara_config<||>
  Package['sahara'] ~> Service['sahara']

  validate_re($database_connection, '(sqlite|mysql|postgresql):\/\/(\S+:\S+@\S+\/\S+)?')

  case $database_connection {
    /^mysql:\/\//: {
      require mysql::bindings
      require mysql::bindings::python
    }
    /^postgresql:\/\//: {
      require postgresql::lib::python
    }
    /^sqlite:\/\//: {
      fail('Sahara does not support sqlite!')
    }
    default: {
      fail('Unsupported db backend configured')
    }
  }

  sahara_config {
    'DEFAULT/use_neutron': value => $use_neutron;
    'DEFAULT/use_floating_ips': value => $use_floating_ips;
    'DEFAULT/host': value => $service_host;
    'DEFAULT/port': value => $service_port;
    'DEFAULT/debug': value => $debug;
    'DEFAULT/verbose': value => $verbose;

    'database/connection':
      value => $database_connection,
      secret => true;

    'keystone_authtoken/auth_uri': value => $os_auth_url;
    'keystone_authtoken/identity_uri': value => $identity_url;
    'keystone_authtoken/admin_user': value => $os_username;
    'keystone_authtoken/admin_tenant_name': value => $os_tenant_name;
    'keystone_authtoken/admin_password':
      value => $os_password,
      secret => true;
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
  }

  Package['sahara'] -> Service['sahara']
  service { 'sahara':
    ensure     => $service_ensure,
    name       => $::sahara::params::service_name,
    hasstatus  => true,
    enable     => $enabled,
    hasrestart => true,
    subscribe  => Exec['sahara-dbmanage'],
  }

  Sahara_config<||> ~> Exec['sahara-dbmanage']

  exec { 'sahara-dbmanage':
    command     => $::sahara::params::dbmanage_command,
    path        => '/usr/bin',
    user        => 'root',
    refreshonly => true,
    logoutput   => on_failure,
  }

}
