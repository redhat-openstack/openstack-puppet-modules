# == Class: neutron::agents:vpnaas::package
#
# Installs Neutron VPN agent.
#
# === Parameters
#
# [*package_ensure*]
#   (optional) Ensure state for package. Defaults to 'present'.
#
class neutron::agents::vpnaas::package (
  $package_ensure = present,
) {

  if $::neutron::params::vpnaas_agent_package {
    Package['neutron']            -> Package['neutron-vpnaas-agent']
    package { 'neutron-vpnaas-agent':
      ensure => $package_ensure,
      name   => $::neutron::params::vpnaas_agent_package,
      tag    => ['openstack', 'neutron-package'],
    }
  }

}
