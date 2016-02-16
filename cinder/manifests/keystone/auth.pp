# == Class: cinder::keystone::auth
#
# Configures Cinder user, service and endpoint in Keystone.
#
# === Parameters
#
# [*password*]
#   Password for Cinder user. Required.
#
# [*email*]
#   Email for Cinder user. Optional. Defaults to 'cinder@localhost'.
#
# [*password_user_v2*]
#   Password for Cinder v2 user. Optional. Defaults to undef.
#
# [*email_user_v2*]
#   Email for Cinder v2 user. Optional. Defaults to 'cinderv2@localhost'.
#
# [*auth_name*]
#   Username for Cinder service. Optional. Defaults to 'cinder'.
#
# [*auth_name_v2*]
#   Username for Cinder v2 service. Optional. Defaults to 'cinderv2'.
#
# [*configure_endpoint*]
#   Should Cinder endpoint be configured? Optional. Defaults to 'true'.
#   API v1 endpoint should be enabled in Icehouse for compatibility with Nova.
#
# [*configure_endpoint_v2*]
#   Should Cinder v2 endpoint be configured? Optional. Defaults to 'true'.
#
# [*configure_user*]
#   Should the service user be configured? Optional. Defaults to 'true'.
#
# [*configure_user_v2*]
#   Should the service user be configured for cinder v2? Optional. Defaults to 'false'.
#
# [*configure_user_role*]
#   Should the admin role be configured for the service user?
#   Optional. Defaults to 'true'.
#
# [*configure_user_role_v2*]
#   Should the admin role be configured for the service user for cinder v2?
#   Optional. Defaults to 'false'.
#
# [*service_name*]
#   (optional) Name of the service.
#   Defaults to the value of auth_name, but must differ from the value
#   of service_name_v2.
#
# [*service_name_v2*]
#   (optional) Name of the v2 service.
#   Defaults to the value of auth_name_v2, but must differ from the value
#   of service_name.
#
# [*service_type*]
#    Type of service. Optional. Defaults to 'volume'.
#
# [*service_type_v2*]
#    Type of API v2 service. Optional. Defaults to 'volumev2'.
#
# [*service_description*]
#    (optional) Description for keystone service.
#    Defaults to 'Cinder Service'.
#
# [*service_description_v2*]
#    (optional) Description for keystone v2 service.
#    Defaults to 'Cinder Service v2'.
#
# [*region*]
#    Region for endpoint. Optional. Defaults to 'RegionOne'.
#
# [*tenant*]
#    Tenant for Cinder user. Optional. Defaults to 'services'.
#
# [*tenant_user_v2*]
#    Tenant for Cinder v2 user. Optional. Defaults to 'services'.
#
# [*public_url*]
#   (optional) The endpoint's public url. (Defaults to 'http://127.0.0.1:8776/v1/%(tenant_id)s')
#   This url should *not* contain any trailing '/'.
#
# [*internal_url*]
#   (optional) The endpoint's internal url. (Defaults to 'http://127.0.0.1:8776/v1/%(tenant_id)s')
#   This url should *not* contain any trailing '/'.
#
# [*admin_url*]
#   (optional) The endpoint's admin url. (Defaults to 'http://127.0.0.1:8776/v1/%(tenant_id)s')
#   This url should *not* contain any trailing '/'.
#
# [*public_url_v2*]
#   (optional) The v2 endpoint's public url. (Defaults to 'http://127.0.0.1:8776/v2/%(tenant_id)s')
#   This url should *not* contain any trailing '/'.
#
# [*internal_url_v2*]
#   (optional) The v2 endpoint's internal url. (Defaults to 'http://127.0.0.1:8776/v2/%(tenant_id)s')
#   This url should *not* contain any trailing '/'.
#
# [*admin_url_v2*]
#   (optional) The v2 endpoint's admin url. (Defaults to 'http://127.0.0.1:8776/v2/%(tenant_id)s')
#   This url should *not* contain any trailing '/'.
#
# === Examples
#
#  class { 'cinder::keystone::auth':
#    public_url   => 'https://10.0.0.10:8776/v1/%(tenant_id)s',
#    internal_url => 'https://10.0.0.20:8776/v1/%(tenant_id)s',
#    admin_url    => 'https://10.0.0.30:8776/v1/%(tenant_id)s',
#  }
#
class cinder::keystone::auth (
  $password,
  $password_user_v2       = undef,
  $auth_name              = 'cinder',
  $auth_name_v2           = 'cinderv2',
  $tenant                 = 'services',
  $tenant_user_v2         = 'services',
  $email                  = 'cinder@localhost',
  $email_user_v2          = 'cinderv2@localhost',
  $public_url             = 'http://127.0.0.1:8776/v1/%(tenant_id)s',
  $internal_url           = 'http://127.0.0.1:8776/v1/%(tenant_id)s',
  $admin_url              = 'http://127.0.0.1:8776/v1/%(tenant_id)s',
  $public_url_v2          = 'http://127.0.0.1:8776/v2/%(tenant_id)s',
  $internal_url_v2        = 'http://127.0.0.1:8776/v2/%(tenant_id)s',
  $admin_url_v2           = 'http://127.0.0.1:8776/v2/%(tenant_id)s',
  $configure_endpoint     = true,
  $configure_endpoint_v2  = true,
  $configure_user         = true,
  $configure_user_v2      = false,
  $configure_user_role    = true,
  $configure_user_role_v2 = false,
  $service_name           = undef,
  $service_name_v2        = undef,
  $service_type           = 'volume',
  $service_type_v2        = 'volumev2',
  $service_description    = 'Cinder Service',
  $service_description_v2 = 'Cinder Service v2',
  $region                 = 'RegionOne',
) {

  $real_service_name = pick($service_name, $auth_name)
  $real_service_name_v2 = pick($service_name_v2, $auth_name_v2)

  if $real_service_name == $real_service_name_v2 {
    fail('cinder::keystone::auth parameters service_name and service_name_v2 must be different.')
  }

  keystone::resource::service_identity { 'cinder':
    configure_user      => $configure_user,
    configure_user_role => $configure_user_role,
    configure_endpoint  => $configure_endpoint,
    service_type        => $service_type,
    service_description => $service_description,
    service_name        => $real_service_name,
    region              => $region,
    auth_name           => $auth_name,
    password            => $password,
    email               => $email,
    tenant              => $tenant,
    public_url          => $public_url,
    admin_url           => $admin_url,
    internal_url        => $internal_url,
  }

  keystone::resource::service_identity { 'cinderv2':
    configure_user      => $configure_user_v2,
    configure_user_role => $configure_user_role_v2,
    configure_endpoint  => $configure_endpoint_v2,
    service_type        => $service_type_v2,
    service_description => $service_description_v2,
    service_name        => $real_service_name_v2,
    region              => $region,
    auth_name           => $auth_name_v2,
    password            => $password_user_v2,
    email               => $email_user_v2,
    tenant              => $tenant_user_v2,
    public_url          => $public_url_v2,
    admin_url           => $admin_url_v2,
    internal_url        => $internal_url_v2,
  }

  if $configure_user_role {
    Keystone_user_role["${auth_name}@${tenant}"] ~> Service <| name == 'cinder-api' |>
    Keystone_user_role["${auth_name}@${tenant}"] -> Cinder::Type <| |>
  }

}
