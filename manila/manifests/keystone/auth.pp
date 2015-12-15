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
# [*service_description*]
#    Description for keystone service. Optional. Defaults to 'Manila Service'.
#
# [*region*]
#    Region for endpoint. Optional. Defaults to 'RegionOne'.
#
# [*tenant*]
#    Tenant for Manila user. Optional. Defaults to 'services'.
#
# [*public_url*]
#   (optional) The endpoint's public url. (Defaults to 'http://127.0.0.1:8786/v1/%(tenant_id)s')
#   This url should *not* contain any trailing '/'.
#
# [*admin_url*]
#   (optional) The endpoint's admin url. (Defaults to 'http://127.0.0.1:8786/v1/%(tenant_id)s')
#   This url should *not* contain any trailing '/'.
#
# [*internal_url*]
#   (optional) The endpoint's internal url. (Defaults to 'http://127.0.0.1:8786/v1/%(tenant_id)s')
#   This url should *not* contain any trailing '/'.
#
# [*password_v2*]
#   Password for Manila v2 user. Optional. Defaults to undef.
#
# [*email_v2*]
#   Email for Manila v2 user. Optional. Defaults to 'manilav2@localhost'.
#
# [*auth_name_v2*]
#   Username for Manila v2 service. Optional. Defaults to 'manilav2'.
#
# [*configure_endpoint_v2*]
#   Should Manila v2 endpoint be configured? Optional. Defaults to 'true'.
#
# [*service_type_v2*]
#    Type of service v2. Optional. Defaults to 'sharev2'.
#
# [*service_description_v2*]
#    Description for keystone service v2. Optional. Defaults to 'Manila Service v2'.
#
# [*public_url_v2*]
#   (optional) The v2 endpoint's public url. (Defaults to 'http://127.0.0.1:8786/v2/%(tenant_id)s')
#   This url should *not* contain any trailing '/'.
#
# [*admin_url_v2*]
#   (optional) The endpoint's admin url. (Defaults to 'http://127.0.0.1:8786/v2/%(tenant_id)s')
#   This url should *not* contain any trailing '/'.
#
# [*internal_url_v2*]
#   (optional) The endpoint's internal url. (Defaults to 'http://127.0.0.1:8786/v2/%(tenant_id)s')
#   This url should *not* contain any trailing '/'.
#
# [*share_version*]
#   (optional) DEPRECATED: Use public_url, internal_url and admin_url instead.
#   API version endpoint. (Defaults to 'v1')
#   Setting this parameter overrides public_url, internal_url and admin_url parameters.
#
# [*port*]
#   (optional) DEPRECATED: Use public_url, internal_url and admin_url instead.
#   Default port for endpoints. (Defaults to 8786)
#   Setting this parameter overrides public_url, internal_url and admin_url parameters.
#
# [*public_protocol*]
#   (optional) DEPRECATED: Use public_url instead.
#   Protocol for public endpoint. (Defaults to 'http')
#   Setting this parameter overrides public_url parameter.
#
# [*public_address*]
#   (optional) DEPRECATED: Use public_url instead.
#   Public address for endpoint. (Defaults to '127.0.0.1')
#   Setting this parameter overrides public_url parameter.
#
# [*internal_protocol*]
#   (optional) DEPRECATED: Use internal_url instead.
#   Protocol for internal endpoint. (Defaults to 'http')
#   Setting this parameter overrides internal_url parameter.
#
# [*internal_address*]
#   (optional) DEPRECATED: Use internal_url instead.
#   Internal address for endpoint. (Defaults to '127.0.0.1')
#   Setting this parameter overrides internal_url parameter.
#
# [*admin_protocol*]
#   (optional) DEPRECATED: Use admin_url instead.
#   Protocol for admin endpoint. (Defaults to 'http')
#   Setting this parameter overrides admin_url parameter.
#
# [*admin_address*]
#   (optional) DEPRECATED: Use admin_url instead.
#   Admin address for endpoint. (Defaults to '127.0.0.1')
#   Setting this parameter overrides admin_url parameter.
#
# === Deprecation notes
#
# If any value is provided for public_protocol, public_address or port parameters,
# public_url will be completely ignored. The same applies for internal and admin parameters.
#
# === Examples
#
#  class { 'manila::keystone::auth':
#    public_url   => 'https://10.0.0.10:8786/v1/%(tenant_id)s',
#    internal_url => 'https://10.0.0.11:8786/v1/%(tenant_id)s',
#    admin_url    => 'https://10.0.0.11:8786/v1/%(tenant_id)s',
#  }
#
class manila::keystone::auth (
  $password,
  $password_v2            = undef,
  $auth_name_v2           = 'manilav2',
  $auth_name              = 'manila',
  $email                  = 'manila@localhost',
  $email_v2               = 'manilav2@localhost',
  $tenant                 = 'services',
  $configure_endpoint     = true,
  $configure_endpoint_v2  = true,
  $service_type           = 'share',
  $service_type_v2        = 'sharev2',
  $service_description    = 'Manila Service',
  $service_description_v2 = 'Manila Service v2',
  $region                 = 'RegionOne',
  $public_url             = 'http://127.0.0.1:8786/v1/%(tenant_id)s',
  $public_url_v2          = 'http://127.0.0.1:8786/v2/%(tenant_id)s',
  $admin_url              = 'http://127.0.0.1:8786/v1/%(tenant_id)s',
  $admin_url_v2           = 'http://127.0.0.1:8786/v2/%(tenant_id)s',
  $internal_url           = 'http://127.0.0.1:8786/v1/%(tenant_id)s',
  $internal_url_v2        = 'http://127.0.0.1:8786/v2/%(tenant_id)s',
  # DEPRECATED PARAMETERS
  $share_version          = undef,
  $port                   = undef,
  $public_protocol        = undef,
  $public_address         = undef,
  $internal_protocol      = undef,
  $internal_address       = undef,
  $admin_protocol         = undef,
  $admin_address          = undef,
) {

  # for interface backward compatibility, we can't enforce to set a new parameter
  # so we take 'password' parameter by default but allow to override it.
  if ! $password_v2 {
    $password_v2_real = $password
  } else {
    $password_v2_real = $password_v2
  }

  if $share_version {
    warning('The share_version parameter is deprecated, use public_url, internal_url and admin_url instead.')
  }

  if $port {
    warning('The port parameter is deprecated, use public_url, internal_url and admin_url instead.')
  }

  if $public_protocol {
    warning('The public_protocol parameter is deprecated, use public_url instead.')
  }

  if $internal_protocol {
    warning('The internal_protocol parameter is deprecated, use internal_url instead.')
  }

  if $admin_protocol {
    warning('The admin_protocol parameter is deprecated, use admin_url instead.')
  }

  if $public_address {
    warning('The public_address parameter is deprecated, use public_url instead.')
  }

  if $internal_address {
    warning('The internal_address parameter is deprecated, use internal_url instead.')
  }

  if $admin_address {
    warning('The admin_address parameter is deprecated, use admin_url instead.')
  }

  if ($public_protocol or $public_address or $port or $share_version) {
    $public_url_real = sprintf('%s://%s:%s/%s/%%(tenant_id)s',
      pick($public_protocol, 'http'),
      pick($public_address, '127.0.0.1'),
      pick($port, '8786'),
      pick($share_version, 'v1'))
  } else {
    $public_url_real = $public_url
  }

  if ($admin_protocol or $admin_address or $port or $share_version) {
    $admin_url_real = sprintf('%s://%s:%s/%s/%%(tenant_id)s',
      pick($admin_protocol, 'http'),
      pick($admin_address, '127.0.0.1'),
      pick($port, '8786'),
      pick($share_version, 'v1'))
  } else {
    $admin_url_real = $admin_url
  }

  if ($internal_protocol or $internal_address or $port or $share_version) {
    $internal_url_real = sprintf('%s://%s:%s/%s/%%(tenant_id)s',
      pick($internal_protocol, 'http'),
      pick($internal_address, '127.0.0.1'),
      pick($port, '8786'),
      pick($share_version, 'v1'))
  } else {
    $internal_url_real = $internal_url
  }

  Keystone_user_role["${auth_name}@${tenant}"] ~> Service <| name == 'manila-api' |>
  Keystone_user_role["${auth_name_v2}@${tenant}"] ~> Service <| name == 'manila-api' |>

  keystone::resource::service_identity { $auth_name:
    configure_user      => true,
    configure_user_role => true,
    configure_endpoint  => $configure_endpoint,
    service_type        => $service_type,
    service_description => $service_description,
    region              => $region,
    password            => $password,
    email               => $email,
    tenant              => $tenant,
    public_url          => $public_url_real,
    admin_url           => $admin_url_real,
    internal_url        => $internal_url_real,
  }

  keystone::resource::service_identity { $auth_name_v2:
    configure_user      => true,
    configure_user_role => true,
    configure_endpoint  => $configure_endpoint_v2,
    service_type        => $service_type_v2,
    service_description => $service_description_v2,
    region              => $region,
    password            => $password_v2_real,
    email               => $email_v2,
    tenant              => $tenant,
    public_url          => $public_url_v2,
    admin_url           => $admin_url_v2,
    internal_url        => $internal_url_v2,
  }
}
