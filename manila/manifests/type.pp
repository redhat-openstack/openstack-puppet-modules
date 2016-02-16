# ==Define: manila::type
#
# Creates manila type and assigns backends.
#
# === Parameters
#
# [*os_password*]
#   (required) The keystone tenant:username password.
#
# [*driver_handles_share_servers*]
#   (required) If the driver handles share servers.
#
# [*set_key*]
#   (optional) Must be used with set_value. Accepts a single string be used
#     as the key in type_set
#
# [*set_value*]
#   (optional) Accepts list of strings or singular string. A list of values
#     passed to type_set
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

define manila::type (
  $os_password,
  $driver_handles_share_servers,
  $set_key                      = undef,
  $set_value                    = undef,
  $os_tenant_name               = 'admin',
  $os_username                  = 'admin',
  $os_auth_url                  = 'http://127.0.0.1:5000/v2.0/',
  $os_region_name               = undef,
  ) {

  $volume_name = $name

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

  exec {"manila type-create ${volume_name} ${driver_handles_share_servers}":
    command     => "manila type-create ${volume_name} ${driver_handles_share_servers}",
    unless      => "manila type-list | grep ${volume_name}",
    environment => concat($manila_env, $region_env),
    require     => Package['python-manilaclient'],
    path        => ['/usr/bin', '/bin'],
  }

  if ($set_value and $set_key) {
    Exec["manila type-create ${volume_name} ${driver_handles_share_servers}"] ->
    manila::type_set { $set_value:
      type           => $volume_name,
      key            => $set_key,
      os_password    => $os_password,
      os_tenant_name => $os_tenant_name,
      os_username    => $os_username,
      os_auth_url    => $os_auth_url,
      os_region_name => $os_region_name,
    }
  }
}
