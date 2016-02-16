# == Class: mistral::keystone::auth
#
# Configures mistral user, service and endpoint in Keystone.
#
# === Parameters
#
# [*password*]
#   (required) Password for mistral user.
#
# [*auth_name*]
#   Username for mistral service. Defaults to 'mistral'.
#
# [*email*]
#   Email for mistral user. Defaults to 'mistral@localhost'.
#
# [*tenant*]
#   Tenant for mistral user. Defaults to 'services'.
#
# [*configure_endpoint*]
#   Should mistral endpoint be configured? Defaults to 'true'.
#
# [*configure_user*]
#   (Optional) Should the service user be configured?
#   Defaults to 'true'.
#
# [*service_type*]
#   Type of service. Defaults to 'workflowv2'.
#
# [*public_url*]
#   (optional) The endpoint's public url.
#   (Defaults to 'http://127.0.0.1:8989:/v2')
#
# [*internal_url*]
#   (optional) The endpoint's internal url.
#   (Defaults to 'http://127.0.0.1:8989/v2')
#
# [*admin_url*]
#   (optional) The endpoint's admin url.
#   (Defaults to 'http://127.0.0.1:8989/v2')
#
# [*region*]
#   Region for endpoint. Defaults to 'RegionOne'.
#
# [*service_name*]
#   (optional) Name of the service.
#   Defaults to the value of auth_name.
#
# [*configure_service*]
#   Should mistral service be configured? Defaults to 'true'.
#
# [*service_description*]
#   (optional) Description for keystone service.
#   Defaults to 'Openstack workflow Service'.

# [*configure_user_role*]
#   (optional) Whether to configure the admin role for the service user.
#   Defaults to true
#
class mistral::keystone::auth(
  $password,
  $email                  = 'mistral@localhost',
  $auth_name              = 'mistral',
  $service_name           = undef,
  $service_type           = 'workflowv2',
  $public_url             = 'http://127.0.0.1:8989/v2',
  $admin_url              = 'http://127.0.0.1:8989/v2',
  $internal_url           = 'http://127.0.0.1:8989/v2',
  $region                 = 'RegionOne',
  $tenant                 = 'services',
  $configure_endpoint     = true,
  $configure_service      = true,
  $configure_user         = true,
  $configure_user_role    = true,
  $service_description    = 'OpenStack Workflow Service',
) {

  validate_string($password)

  if $service_name == undef {
    $real_service_name = $auth_name
  } else {
    $real_service_name = $service_name
  }

  keystone::resource::service_identity { $auth_name:
    configure_user      => $configure_user,
    configure_user_role => $configure_user_role,
    configure_endpoint  => $configure_endpoint,
    service_type        => $service_type,
    service_description => $service_description,
    service_name        => $real_service_name,
    region              => $region,
    password            => $password,
    email               => $email,
    tenant              => $tenant,
    public_url          => $public_url,
    admin_url           => $admin_url,
    internal_url        => $internal_url,
  }
}
