# Class for Nagios Remote Plugin Executor
class nagios::client (
  $monitored_ip,
  $nagios_server_host,
  $hostgroups = $nagios::params::hostgroups,
) inherits nagios::params {

  include nagios::params

  package { ['nrpe', 'nagios-plugins-load', 'nagios-plugins-disk']:
    ensure => present,
  } ->

  file_line { 'server_address':
    path   => '/etc/nagios/nrpe.cfg',
    match  => 'server_address=',
    line   => "server_address=${monitored_ip}",
  } ->

  file_line { 'allowed_hosts':
    path   => '/etc/nagios/nrpe.cfg',
    match  => 'allowed_hosts=',
    line   => "allowed_hosts=127.0.0.1,${nagios_server_host}",
  } ->

  file_line {'check_disk_var':
    path => '/etc/nagios/nrpe.cfg',
    line => 'command[check_disk_var]=/usr/lib64/nagios/plugins/check_disk -w 10% -c 5% -p /var',
  } ->

  file_line {'virsh_nodeinfo':
    path => '/etc/nagios/nrpe.cfg',
    line => 'command[virsh_nodeinfo]=/usr/lib64/nagios/plugins/virsh_nodeinfo',
  } ->

  file {'/usr/lib64/nagios/plugins/virsh_nodeinfo':
    mode    => '0755',
    seltype => 'nagios_unconfined_plugin_exec_t',
    content => template('nagios/virsh_nodeinfo.erb')
  } ~>

  service {'nrpe':
    ensure    => running,
    enable    => true,
    hasstatus => true,
  }

  $services = "${::openstack_services_enabled}"

  $hg = hostgroups_by_services($hostgroups, $services)

  if "${settings::storeconfigs_backend}" == 'puppetdb' {
    @@nagios_host {"${::fqdn}":
      address    => "${monitored_ip}",
      hostgroups => "openstack,${hg}",
      notes      => "${services}",
      use        => 'linux-server',
    }
  }
  else {
    nagios_host_add("${::fqdn}",
      { address    => "${monitored_ip}",
        hostgroups => "openstack,${hg}",
        notes      => "${services}",
        use        => 'linux-server',
      }
    )
  }
}
