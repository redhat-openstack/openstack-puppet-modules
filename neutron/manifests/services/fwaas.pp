#
# Copyright (C) 2013 eNovance SAS <licensing@enovance.com>
#
# Author: Emilien Macchi <emilien.macchi@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
#
# == Class: neutron::services::fwaas
#
# Configure the Firewall as a Service Neutron Plugin
#
# === Parameters:
#
# [*enabled*]
#   (optional) Whether or not to enable the FWaaS neutron plugin Service
#   Defaults to $::os_service_default
#
# [*driver*]
#   (optional) FWaaS Driver to use
#   Defaults to $::os_service_default
#
# [*vpnaas_agent_package*]
#   (optional) Use VPNaaS agent package instead of L3 agent package on debian platforms
#   RedHat platforms won't take care of this parameter
#   true/false
#   Defaults to false
#

class neutron::services::fwaas (
  $enabled              = $::os_service_default,
  $driver               = $::os_service_default,
  $vpnaas_agent_package = false
) {

  include ::neutron::params

  # FWaaS needs to be enabled before starting Neutron L3 agent
  Neutron_fwaas_service_config<||> ~> Service['neutron-l3']

  if ($::osfamily == 'Debian') {
    # Debian platforms
    if $vpnaas_agent_package {
      ensure_resource( 'package', $::neutron::params::vpnaas_agent_package, {
        'ensure' => $neutron::package_ensure,
        'tag'    => 'openstack'
      })
      Package[$::neutron::params::vpnaas_agent_package] -> Neutron_fwaas_service_config<||>
    }
    else {
      ensure_resource( 'package', 'neutron-fwaas' , {
        'name'   => $::neutron::params::fwaas_package,
        'ensure' => $neutron::package_ensure,
        'tag'    => 'openstack'
      })
    }
  } elsif($::osfamily == 'Redhat') {
    # RH platforms
    ensure_resource( 'package', 'neutron-fwaas', {
      'name'   => $::neutron::params::fwaas_package,
      'ensure' => $neutron::package_ensure,
      'tag'    => 'openstack'
    })
  }

  neutron_fwaas_service_config {
    'fwaas/enabled': value => $enabled;
    'fwaas/driver':  value => $driver;
  }
}
