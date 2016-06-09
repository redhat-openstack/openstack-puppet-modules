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

# gnocchi::storage
#
# Storage backend for Gnocchi
#
# == Parameters
#
# [*package_ensure*]
#   (optional) ensure state for package.
#   Defaults to 'present'
#
# [*coordination_url*]
#   (optional) The url to use for distributed group membership coordination.
#   Defaults to $::os_service_default.
#

class gnocchi::storage(
  $package_ensure   = 'present',
  $coordination_url = $::os_service_default,
) inherits gnocchi::params {

  package { 'gnocchi-carbonara':
    ensure => $package_ensure,
    name   => $::gnocchi::params::carbonara_package_name,
    tag    => ['openstack', 'gnocchi-package'],
  }

  gnocchi_config {
    'storage/coordination_url' : value => $coordination_url;
  }

}
