# == Class: contrail::service_token
#
# Install the /etc/contrail/service.token
#
# === Parameters:
#
# [*keystone_service_token*]
#   (optional) Keystone service token
#   Defaults to ''
#
class contrail::service_token (
  $keystone_service_token = '',
) {

  file { '/etc/contrail/service.token' :
    ensure  => file,
    content => $keystone_service_token,
  }

}
