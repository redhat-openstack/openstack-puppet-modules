# == Class: gnocchi::keystone::auth
#
# Configures Gnocchi user, service and endpoint in Keystone.
#
# === Parameters
#
# [*password*]
#   (required) Password for gnocchi user.
#
# [*auth_name*]
#   Username for gnocchi service. Defaults to 'gnocchi'.
#
# [*email*]
#   Email for gnocchi user. Defaults to 'gnocchi@localhost'.
#
# [*tenant*]
#   Tenant for gnocchi user. Defaults to 'services'.
#
# [*configure_endpoint*]
#   Should gnocchi endpoint be configured? Defaults to 'true'.
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
#   Type of service. Defaults to 'key-manager'.
#
# [*region*]
#   Region for endpoint. Defaults to 'RegionOne'.
#
# [*service_name*]
#   (optional) Name of the service.
#   Defaults to the value of auth_name.
#
# [*public_url*]
#   (optional) The endpoint's public url. (Defaults to 'http://127.0.0.1:8041')
#   This url should *not* contain any trailing '/'.
#
# [*admin_url*]
#   (optional) The endpoint's admin url. (Defaults to 'http://127.0.0.1:8041')
#   This url should *not* contain any trailing '/'.
#
# [*internal_url*]
#   (optional) The endpoint's internal url. (Defaults to 'http://127.0.0.1:8041')
#   This url should *not* contain any trailing '/'.
#
class gnocchi::keystone::auth (
  $password,
  $auth_name           = 'gnocchi',
  $email               = 'gnocchi@localhost',
  $tenant              = 'services',
  $configure_endpoint  = true,
  $configure_user      = true,
  $configure_user_role = true,
  $service_name        = undef,
  $service_type        = 'metric',
  $region              = 'RegionOne',
  $public_url          = 'http://127.0.0.1:8041',
  $internal_url        = 'http://127.0.0.1:8041',
  $admin_url           = 'http://127.0.0.1:8041',
) {

  $real_service_name    = pick($service_name, $auth_name)

  keystone::resource::service_identity { 'gnocchi':
    configure_user      => $configure_user,
    configure_user_role => $configure_user_role,
    configure_endpoint  => $configure_endpoint,
    service_name        => $real_service_name,
    service_type        => $service_type,
    service_description => 'OpenStack Metric Service',
    region              => $region,
    auth_name           => $auth_name,
    password            => $password,
    email               => $email,
    tenant              => $tenant,
    public_url          => $public_url,
    internal_url        => $internal_url,
    admin_url           => $admin_url,
  }

}
