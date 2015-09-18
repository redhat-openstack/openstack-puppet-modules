# == Class: aodh::keystone::auth
#
# Configures aodh user, service and endpoint in Keystone.
#
# === Parameters
#
# [*password*]
#   (required) Password for aodh user.
#
# [*auth_name*]
#   Username for aodh service. Defaults to 'aodh'.
#
# [*email*]
#   Email for aodh user. Defaults to 'aodh@localhost'.
#
# [*tenant*]
#   Tenant for aodh user. Defaults to 'services'.
#
# [*configure_endpoint*]
#   Should aodh endpoint be configured? Defaults to 'true'.
#
# [*configure_user*]
#   (Optional) Should the service user be configured?
#   Defaults to 'true'.
#
# [*configure_user_role*]
#   (Optional) Should the admin role be configured for the service user?
#   Defaults to 'true'.
#
# [*service_type*]
#   Type of service. Defaults to 'alarming'.
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
#   Port for endpoint. Defaults to '8042'.
#
# [*public_port*]
#   Port for public endpoint. Defaults to $port.
#
# [*region*]
#   Region for endpoint. Defaults to 'RegionOne'.
#
# [*service_name*]
#   (optional) Name of the service.
#   Defaults to the value of auth_name.
#
#
class aodh::keystone::auth (
  $password,
  $auth_name           = 'aodh',
  $email               = 'aodh@localhost',
  $tenant              = 'services',
  $configure_endpoint  = true,
  $configure_user      = true,
  $configure_user_role = true,
  $service_name        = undef,
  $service_type        = 'alarming',
  $public_protocol     = 'http',
  $public_address      = '127.0.0.1',
  $admin_protocol      = 'http',
  $admin_address       = '127.0.0.1',
  $internal_protocol   = 'http',
  $internal_address    = '127.0.0.1',
  $port                = '8042',
  $public_port         = undef,
  $region              = 'RegionOne'
) {

  $real_service_name    = pick($service_name, $auth_name)

  if $configure_user_role {
    Keystone_user_role["${auth_name}@${tenant}"] ~> Service <| name == 'aodh-server' |>
  }
  Keystone_endpoint["${region}/${real_service_name}"]  ~> Service <| name == 'aodh-server' |>

  if ! $public_port {
    $real_public_port = $port
  } else {
    $real_public_port = $public_port
  }

  keystone::resource::service_identity { 'aodh':
    configure_user      => $configure_user,
    configure_user_role => $configure_user_role,
    configure_endpoint  => $configure_endpoint,
    service_name        => $real_service_name,
    service_type        => $service_type,
    service_description => 'AODH Alarming Service',
    region              => $region,
    auth_name           => $auth_name,
    password            => $password,
    email               => $email,
    tenant              => $tenant,
    public_url          => "${public_protocol}://${public_address}:${real_public_port}/",
    internal_url        => "${internal_protocol}://${internal_address}:${port}/",
    admin_url           => "${admin_protocol}://${admin_address}:${port}/",
  }

}
