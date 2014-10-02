# Nagios server configuration
class nagios::server::base(
  $admin_password,
  $admin_name,
  $admin_user,
  $admin_group,
) {

  File {
    owner => $admin_user,
    group => $admin_group,
  }

  file { ['/etc/nagios/conf.d/commands.cfg', '/etc/nagios/conf.d/hosts.cfg', '/etc/nagios/conf.d/hostgroups.cfg', '/etc/nagios/conf.d/services.cfg']:
    ensure => 'present',
    mode   => 644,
  }

  exec { 'nagiospasswd':
    command => "/usr/bin/htpasswd -b /etc/nagios/passwd $admin_name $admin_password",
  }

  # Remove the entry for localhost, it contains services we're not
  # monitoring
  file { ['/etc/nagios/objects/localhost.cfg']:
    ensure  => 'present',
    content => '',
  }
}
