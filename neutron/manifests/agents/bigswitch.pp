# == Class: neutron::agents::bsn
#
# Installs and configures the Big Switch's bsn agent
#
# === Parameters
#
# [*package_ensure*]
#   (optional) The state of the package
#   Defaults to present
#
# [*enabled*]
#   (optional) The state of the service
#   Defaults to true
#
# [*manage_service*]
#   (optional) Whether to start/stop the service
#   Defaults to true
#
#
class neutron::agents::bigswitch (
  $package_ensure                   = 'present',
  $lldp_enabled                     = true,
  $agent_enabled                    = false,
) {

  if($::osfamily != 'Redhat') {
    fail("Unsupported osfamily ${::osfamily}")
  }

  require ::neutron::plugins::ml2::bigswitch

  package { 'lldp':
    ensure  => $package_ensure,
    name    => $::neutron::params::bigswitch_lldp_package
  }

  package { 'agent':
    ensure  => $package_ensure,
    name    => $::neutron::params::bigswitch_agent_package
  }

  if $lldp_enabled {
    $lldp_service_ensure = 'running'
  } else {
    $lldp_service_ensure = 'stopped'
  }

  if $agent_enabled {
    $agent_service_ensure = 'running'
  } else {
    $agent_service_ensure = 'stopped'
  }

  service { 'lldp':
    ensure  => $lldp_service_ensure,
    name    => $::neutron::params::bigswitch_lldp_service,
    enable  => $lldp_enabled,
    require => [Class['neutron'], Package['lldp']],
    tag     => 'neutron-service',
  }

  service { 'agent':
    ensure  => $agent_service_ensure,
    name    => $::neutron::params::bigswitch_agent_service,
    enable  => $agent_enabled,
    require => [Class['neutron'], Package['agent']],
    tag     => 'neutron-service',
  }
}
