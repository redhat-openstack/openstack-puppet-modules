# == Class: neutron::agents::dhcp
#
# Setups Neutron DHCP agent.
#
# === Parameters
#
# [*package_ensure*]
#   (optional) Ensure state for package. Defaults to 'present'.
#
# [*enabled*]
#   (optional) Enable state for service. Defaults to 'true'.
#
# [*manage_service*]
#   (optional) Whether to start/stop the service
#   Defaults to true
#
# [*debug*]
#   (optional) Show debugging output in log. Defaults to $::os_service_default.
#
# [*state_path*]
#   (optional) Where to store dnsmasq state files. This directory must be
#   writable by the user executing the agent. Defaults to '/var/lib/neutron'.
#
# [*resync_interval*]
#   (optional) The DHCP agent will resync its state with Neutron to recover
#   from any transient notification or rpc errors. The interval is number of
#   seconds between attempts. Defaults to 30.
#
# [*interface_driver*]
#   (optional) Defaults to 'neutron.agent.linux.interface.OVSInterfaceDriver'.
#
# [*dhcp_driver*]
#   (optional) Defaults to 'neutron.agent.linux.dhcp.Dnsmasq'.
#
# [*root_helper*]
#   (optional) Defaults to 'sudo neutron-rootwrap /etc/neutron/rootwrap.conf'.
#   Addresses bug: https://bugs.launchpad.net/neutron/+bug/1182616
#   Note: This can safely be removed once the module only targets the Havana release.
#
# [*dnsmasq_config_file*]
#   (optional) Override the default dnsmasq settings with this file.
#   Defaults to $::os_service_default
#
# [*dnsmasq_dns_servers*]
#  (optional) List of servers to use as dnsmasq forwarders.
#  Defaults to $::os_service_default.
#
# [*enable_isolated_metadata*]
#   (optional) enable metadata support on isolated networks.
#   Defaults to false.
#
# [*enable_force_metadata*]
#   (optional) enable metadata support on all networks.
#   Defaults to $::os_service_default
#
# [*enable_metadata_network*]
#   (optional) Allows for serving metadata requests coming from a dedicated metadata
#   access network whose cidr is 169.254.169.254/16 (or larger prefix), and is
#   connected to a Neutron router from which the VMs send metadata request.
#   This option requires enable_isolated_metadata = True
#   Defaults to false.
#
# [*dhcp_broadcast_reply*]
#  (optional) Use broadcast in DHCP replies
#  Defaults to $::os_service_default.
#
# === Deprecated Parameters
#
# [*dhcp_delete_namespaces*]
#   (optional) Deprecated. Delete namespace after removing a dhcp server
#   Defaults to $::os_service_default.
#
# [*dhcp_domain*]
#   (optional) Deprecated. Domain to use for building the hostnames
#   Defaults to $::os_service_default
#
# [*use_namespaces*]
#   (optional) Deprecated. 'True' value will be enforced in future releases.
#   Allow overlapping IP (Must have kernel build with
#   CONFIG_NET_NS=y and iproute2 package that supports namespaces).
#   Defaults to $::os_service_default.
#
class neutron::agents::dhcp (
  $package_ensure           = present,
  $enabled                  = true,
  $manage_service           = true,
  $debug                    = $::os_service_default,
  $state_path               = '/var/lib/neutron',
  $resync_interval          = 30,
  $interface_driver         = 'neutron.agent.linux.interface.OVSInterfaceDriver',
  $dhcp_driver              = 'neutron.agent.linux.dhcp.Dnsmasq',
  $root_helper              = 'sudo neutron-rootwrap /etc/neutron/rootwrap.conf',
  $dnsmasq_config_file      = $::os_service_default,
  $dnsmasq_dns_servers      = $::os_service_default,
  $enable_isolated_metadata = false,
  $enable_force_metadata    = $::os_service_default,
  $enable_metadata_network  = false,
  $dhcp_broadcast_reply     = $::os_service_default,
  # DEPRECATED PARAMETERS
  $dhcp_delete_namespaces   = $::os_service_default,
  $dhcp_domain              = $::os_service_default,
  $use_namespaces           = $::os_service_default,
) {

  include ::neutron::params

  Neutron_config<||>            ~> Service['neutron-dhcp-service']
  Neutron_dhcp_agent_config<||> ~> Service['neutron-dhcp-service']

  case $dhcp_driver {
    /\.Dnsmasq/: {
      Package[$::neutron::params::dnsmasq_packages] -> Package<| title == 'neutron-dhcp-agent' |>
      ensure_packages($::neutron::params::dnsmasq_packages)
    }
    /^midonet.*/: {
      ensure_packages($::neutron::params::midonet_server_package)
    }
    default: {
      fail("Unsupported dhcp_driver ${dhcp_driver}")
    }
  }

  if (! ($enable_isolated_metadata or $enable_force_metadata)) and $enable_metadata_network {
    fail('enable_metadata_network to true requires enable_isolated_metadata or enable_force_metadata also enabled.')
  } else {
    neutron_dhcp_agent_config {
      'DEFAULT/enable_isolated_metadata': value => $enable_isolated_metadata;
      'DEFAULT/force_metadata':           value => $enable_force_metadata;
      'DEFAULT/enable_metadata_network':  value => $enable_metadata_network;
    }
  }

  # The DHCP agent loads both neutron.ini and its own file.
  # This only lists config specific to the agent.  neutron.ini supplies
  # the rest.
  neutron_dhcp_agent_config {
    'DEFAULT/debug':                  value => $debug;
    'DEFAULT/state_path':             value => $state_path;
    'DEFAULT/resync_interval':        value => $resync_interval;
    'DEFAULT/interface_driver':       value => $interface_driver;
    'DEFAULT/dhcp_domain':            value => $dhcp_domain;
    'DEFAULT/dhcp_driver':            value => $dhcp_driver;
    'DEFAULT/root_helper':            value => $root_helper;
    'DEFAULT/dhcp_broadcast_reply':   value => $dhcp_broadcast_reply;
    'DEFAULT/dnsmasq_config_file':    value => $dnsmasq_config_file;
    'DEFAULT/dnsmasq_dns_servers':    value => join(any2array($dnsmasq_dns_servers), ',');
  }

  if ! is_service_default ($dhcp_delete_namespaces) {
    warning('The dhcp_delete_namespaces parameter was removed in Mitaka, it does not take any affect')
  }

  if ! is_service_default ($dhcp_domain) {
    warning('The dhcp_domain parameter is deprecated and will be removed in future releases')
  }

  if ! is_service_default ($use_namespaces) {
    warning('The use_namespaces parameter is deprecated and will be removed in future releases')
    neutron_dhcp_agent_config {
      'DEFAULT/use_namespaces':       value => $use_namespaces;
    }
  }

  if $::neutron::params::dhcp_agent_package {
    Package['neutron']            -> Package['neutron-dhcp-agent']
    Package['neutron-dhcp-agent'] -> Neutron_config<||>
    Package['neutron-dhcp-agent'] -> Neutron_dhcp_agent_config<||>
    package { 'neutron-dhcp-agent':
      ensure => $package_ensure,
      name   => $::neutron::params::dhcp_agent_package,
      tag    => ['openstack', 'neutron-package'],
    }
  } else {
    # Some platforms (RedHat) do not provide a neutron DHCP agent package.
    # The neutron DHCP agent config file is provided by the neutron package.
    Package['neutron'] -> Neutron_dhcp_agent_config<||>
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
    Package['neutron'] ~> Service['neutron-dhcp-service']
    if $::neutron::params::dhcp_agent_package {
      Package['neutron-dhcp-agent'] ~> Service['neutron-dhcp-service']
    }
  }

  service { 'neutron-dhcp-service':
    ensure  => $service_ensure,
    name    => $::neutron::params::dhcp_agent_service,
    enable  => $enabled,
    require => Class['neutron'],
    tag     => 'neutron-service',
  }
}
