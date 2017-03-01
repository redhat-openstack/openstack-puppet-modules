# == Class: contrail::ctrl_details
#
# Install the /etc/contrail/ctrl-details file
#
# === Parameters:
#
# [*keystone_service_token*]
#   (optional) Keystone service token
#   Defaults to ''
#
# [*keystone_auth_protocol*]
#   (optional) Keystone authentication protocol
#   Defaults to 'http'
#
# [*keystone_admin_password*]
#   (optional) Keystone admin password
#   Defaults to 'password'
#
# [*openstack_internal_vip*]
#   (optional) Openstack internal VIP
#   Defaults to '127.0.0.1'
#
# [*openstack_external_vip*]
#   (optional) Openstack external VIP
#   Defaults to '127.0.0.1'
#
# [*amqp_ip*]
#   (optional) IP of the AMQP broket
#   Defaults to '127.0.0.1'
#
class contrail::ctrl_details (
  $keystone_service_token  = '',
  $keystone_auth_protocol  = 'http',
  $keystone_admin_password = 'password',
  $openstack_internal_vip  = '127.0.0.1',
  $openstack_external_vip  = '127.0.0.1',
  $amqp_ip                 = '127.0.0.1',
) {

  file { '/etc/contrail/ctrl-details' :
    ensure  => file,
    content => template('contrail/ctrl-details.erb'),
  }

}
