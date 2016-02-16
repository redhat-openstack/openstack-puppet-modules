# ==Define: manila::type_set
#
# Assigns keys after the share type is set.
#
# === Parameters
#
# [*os_password*]
#   (required) The keystone tenant:username password.
#
# [*type*]
#   (required) Accepts single name of type to set.
#
# [*key*]
#   (required) the key name that we are setting the value for.
#
# [*os_tenant_name*]
#   (optional) The keystone tenant name. Defaults to 'admin'.
#
# [*os_username*]
#   (optional) The keystone user name. Defaults to 'admin.
#
# [*os_auth_url*]
#   (optional) The keystone auth url. Defaults to 'http://127.0.0.1:5000/v2.0/'.
#
# [*os_region_name*]
#   (optional) The keystone region name. Default is unset.
#
# Author: Andrew Woodward <awoodward@mirantis.com>


define manila::type_set (
  $type,
  $key,
  $os_password,
  $os_tenant_name = 'admin',
  $os_username    = 'admin',
  $os_auth_url    = 'http://127.0.0.1:5000/v2.0/',
  $os_region_name = undef,
  ) {

  include ::manila::client

# TODO: (xarses) This should be moved to a ruby provider so that among other
#   reasons, the credential discovery magic can occur like in neutron.

  $manila_env = [
    "OS_TENANT_NAME=${os_tenant_name}",
    "OS_USERNAME=${os_username}",
    "OS_PASSWORD=${os_password}",
    "OS_AUTH_URL=${os_auth_url}",
  ]

  if $os_region_name {
    $region_env = ["OS_REGION_NAME=${os_region_name}"]
  }
  else {
    $region_env = []
  }

  exec {"manila type-key ${type} set ${key}=${name}":
    path        => ['/usr/bin', '/bin'],
    command     => "manila type-key ${type} set ${key}=${name}",
    environment => concat($manila_env, $region_env),
    require     => Package['python-manilaclient'],
  }
}
