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
# gnocchi::keystone::auth
#
# Configures Gnocchi user, service and endpoint in Keystone.
#
# === Parameters
#
# [*password*]
#   (required) Password for Gnocchi user.
#
# [*auth_name*]
#   Username for Gnocchi service. Defaults to 'gnocchi'.
#
# [*email*]
#   Email for Gnocchi user. Defaults to 'gnocchi@localhost'.
#
# [*tenant*]
#   Tenant for Gnocchi user. Defaults to 'services'.
#
# [*configure_endpoint*]
#   Should Gnocchi endpoint be configured? Defaults to 'true'.
#
# [*configure_user*]
#   Should Gnocchi user be configured? Defaults to 'true'.
#
# [*configure_user_role*]
#   Should Gnocchi user/role association be configured? Defaults to 'true'.
#
# [*service_type*]
#   Type of service. Defaults to 'gnocchi'.
#
# [*public_protocol*]
#   Protocol for public endpoint. Defaults to 'http'.
#
# [*public_address*]
#   Public address for endpoint. Defaults to '127.0.0.1'.
#
# [*public_port*]
#   Port for public endpoint.
#   Defaults to '8041'.
#
# [*admin_protocol*]
#   Protocol for admin endpoint. Defaults to 'http'.
#
# [*admin_address*]
#   Admin address for endpoint. Defaults to '127.0.0.1'.
#
# [*admin_port*]
#   Port for admin endpoint.
#   Defaults to '8041'.
#
# [*internal_protocol*]
#   Protocol for internal endpoint. Defaults to 'http'.
#
# [*internal_address*]
#   Internal address for endpoint. Defaults to '127.0.0.1'.
#
# [*internal_port*]
#   Port for internal endpoint.
#   Defaults to '8041'.
#
# [*region*]
#   Region for endpoint. Defaults to 'RegionOne'.
#
#
class gnocchi::keystone::auth (
  $password,
  $auth_name           = 'gnocchi',
  $email               = 'gnocchi@localhost',
  $tenant              = 'services',
  $configure_endpoint  = true,
  $configure_user      = true,
  $configure_user_role = true,
  $service_type        = 'gnocchi',
  $public_protocol     = 'http',
  $public_address      = '127.0.0.1',
  $public_port         = '8041',
  $admin_protocol      = 'http',
  $admin_address       = '127.0.0.1',
  $admin_port          = '8041',
  $internal_protocol   = 'http',
  $internal_address    = '127.0.0.1',
  $internal_port       = '8041',
  $region              = 'RegionOne'
) {

  Keystone_user_role["${auth_name}@${tenant}"] ~> Service <| name == 'gnocchi-api' |>
  Keystone_endpoint["${region}/${auth_name}"]  ~> Service <| name == 'gnocchi-api' |>

  keystone::resource::service_identity { $auth_name:
    configure_user      => true,
    configure_user_role => true,
    configure_endpoint  => $configure_endpoint,
    service_type        => $service_type,
    service_description => 'OpenStack Datapoint Service',
    region              => $region,
    password            => $password,
    email               => $email,
    tenant              => $tenant,
    public_url          => "${public_protocol}://${public_address}:${public_port}",
    internal_url        => "${internal_protocol}://${internal_address}:${internal_port}",
    admin_url           => "${admin_protocol}://${admin_address}:${admin_port}",
  }

}
