#
# Copyright (C) 2014 eNovance SAS <licensing@enovance.com>
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
# tuskar::keystone::auth
#
# Configures Tuskar user, service and endpoint in Keystone.
#
# === Parameters
#
# [*password*]
#   (required) Password for Tuskar user.
#
# [*auth_name*]
#   Username for Tuskar service. Defaults to 'tuskar'.
#
# [*email*]
#   Email for Tuskar user. Defaults to 'tuskar@localhost'.
#
# [*tenant*]
#   Tenant for Tuskar user. Defaults to 'services'.
#
# [*configure_endpoint*]
#   Should Tuskar endpoint be configured? Defaults to 'true'.
#
# [*service_type*]
#   Type of service. Defaults to 'management'.
#
# [*public_protocol*]
#   Protocol for public endpoint. Defaults to 'http'.
#
# [*public_address*]
#   Public address for endpoint. Defaults to '127.0.0.1'.
#
# [*admin_protocol*]
#   Protocol for admin endpoint. Defaults to 'http'.
#
# [*admin_address*]
#   Admin address for endpoint. Defaults to '127.0.0.1'.
#
# [*internal_protocol*]
#   Protocol for internal endpoint. Defaults to 'http'.
#
# [*internal_address*]
#   Internal address for endpoint. Defaults to '127.0.0.1'.
#
# [*port*]
#   Port for endpoint. Defaults to '8585'.
#
# [*public_port*]
#   Port for public endpoint. Defaults to $port.
#
# [*region*]
#   Region for endpoint. Defaults to 'RegionOne'.
#
#
class tuskar::keystone::auth (
  $password,
  $auth_name          = 'tuskar',
  $email              = 'tuskar@localhost',
  $tenant             = 'services',
  $configure_endpoint = true,
  $service_type       = 'management',
  $public_protocol    = 'http',
  $public_address     = '127.0.0.1',
  $admin_protocol     = 'http',
  $admin_address      = '127.0.0.1',
  $internal_protocol  = 'http',
  $internal_address   = '127.0.0.1',
  $port               = '8585',
  $public_port        = undef,
  $region             = 'RegionOne'
) {

  Keystone_user_role["${auth_name}@${tenant}"] ~> Service <| name == 'tuskar-api' |>
  Keystone_endpoint["${region}/${auth_name}"]  ~> Service <| name == 'tuskar-api' |>

  if ! $public_port {
    $real_public_port = $port
  } else {
    $real_public_port = $public_port
  }

  keystone::resource::service_identity { $auth_name:
    configure_user      => true,
    configure_user_role => true,
    configure_endpoint  => $configure_endpoint,
    service_type        => $service_type,
    service_description => 'Tuskar Management Service',
    region              => $region,
    password            => $password,
    email               => $email,
    tenant              => $tenant,
    public_url          => "${public_protocol}://${public_address}:${real_public_port}",
    internal_url        => "${internal_protocol}://${internal_address}:${port}",
    admin_url           => "${admin_protocol}://${admin_address}:${port}",
  }

}
