# == Class: manila::keystone::auth
#
# Configures Manila user, service and endpoint in Keystone.
#
# === Parameters
#
# [*password*]
#   Password for Manila user. Required.
#
# [*email*]
#   Email for Manila user. Optional. Defaults to 'manila@localhost'.
#
# [*auth_name*]
#   Username for Manila service. Optional. Defaults to 'manila'.
#
# [*configure_endpoint*]
#   Should Manila endpoint be configured? Optional. Defaults to 'true'.
#   API v1 endpoint should be enabled in Icehouse for compatibility with Nova.
#
# [*service_type*]
#    Type of service. Optional. Defaults to 'share'.
#
# [*public_address*]
#    Public address for endpoint. Optional. Defaults to '127.0.0.1'.
#
# [*admin_address*]
#    Admin address for endpoint. Optional. Defaults to '127.0.0.1'.
#
# [*internal_address*]
#    Internal address for endpoint. Optional. Defaults to '127.0.0.1'.
#
# [*port*]
#    Port for endpoint. Optional. Defaults to '8786'.
#
# [*share_version*]
#    Manila API version. Optional. Defaults to 'v1'.
#
# [*region*]
#    Region for endpoint. Optional. Defaults to 'RegionOne'.
#
# [*tenant*]
#    Tenant for Manila user. Optional. Defaults to 'services'.
#
# [*public_protocol*]
#    Protocol for public endpoint. Optional. Defaults to 'http'.
#
# [*internal_protocol*]
#    Protocol for internal endpoint. Optional. Defaults to 'http'.
#
# [*admin_protocol*]
#    Protocol for admin endpoint. Optional. Defaults to 'http'.
#
class manila::keystone::auth (
  $password,
  $auth_name             = 'manila',
  $email                 = 'manila@localhost',
  $tenant                = 'services',
  $configure_endpoint    = true,
  $service_type          = 'share',
  $public_address        = '127.0.0.1',
  $admin_address         = '127.0.0.1',
  $internal_address      = '127.0.0.1',
  $port                  = '8786',
  $share_version         = 'v1',
  $region                = 'RegionOne',
  $public_protocol       = 'http',
  $admin_protocol        = 'http',
  $internal_protocol     = 'http'
) {

  Keystone_user_role["${auth_name}@${tenant}"] ~> Service <| name == 'manila-api' |>

  keystone::resource::service_identity { $auth_name:
    configure_user      => true,
    configure_user_role => true,
    configure_endpoint  => $configure_endpoint,
    service_type        => $service_type,
    service_description => 'Manila Service',
    region              => $region,
    password            => $password,
    email               => $email,
    tenant              => $tenant,
    public_url          => "${public_protocol}://${public_address}:${port}/${share_version}/%(tenant_id)s",
    admin_url           => "${admin_protocol}://${admin_address}:${port}/${share_version}/%(tenant_id)s",
    internal_url        => "${internal_protocol}://${internal_address}:${port}/${share_version}/%(tenant_id)s",
  }

}
