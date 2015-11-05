# == Class: contrail::control::provision_control
#
# Provision the control node
#
# === Parameters:
#
# [*api_address*]
#   (optional) IP address of the Contrail API
#   Defaults to '127.0.0.1'
#
# [*api_port*]
#   (optional) Port of the Contrail API
#   Defaults to 8082
#
# [*router_asn*]
#   (optional) The router ASN
#   Defaults 64512
#
# [*control_node_address*]
#   (optional) IP address of the controller
#   Defaults to $::ipaddress
#
# [*control_node_name*]
#   (optional) Hostname of the controller
#   Defaults to $::hostname
#
# [*keystone_admin_user*]
#   (optional) Keystone admin user
#   Defaults to 'admin'
#
# [*keystone_admin_password*]
#   (optional) Password for keystone admin user
#   Defaults to 'password'
#
# [*keystone_admin_tenant_name*]
#   (optional) Keystone admin tenant name
#   Defaults to 'admin'
#
# [*ibgp_auto_mesh*]
#   (optional) Should iBGP auto mesh activated
#   Defaults to 'true'
#
# [*oper*]
#   (optional) Operation to run (add|del)
#   Defaults to 'add'
#
class contrail::control::provision_control (
  $api_address                = '127.0.0.1',
  $api_port                   = 8082,
  $router_asn                 = 64512,
  $control_node_address       = $::ipaddress,
  $control_node_name          = $::hostname,
  $keystone_admin_user        = 'admin',
  $keystone_admin_password    = 'password',
  $keystone_admin_tenant_name = 'admin',
  $ibgp_auto_mesh             = true,
  $oper                       = 'add',
) {

  if $ibgp_auto_mesh {
    $ibgp_auto_mesh_opt = '--ibgp_auto_mesh'
  } else {
    $ibgp_auto_mesh_opt = '--no_ibgp_auto_mesh'
  }

  exec { "provision_control.py ${control_node_name}" :
    command => "python /opt/contrail/utils/provision_control.py \
                 --host_name ${control_node_name} \
                 --host_ip ${control_node_address} \
                 --router_asn ${router_asn} \
                 ${ibgp_auto_mesh_opt} \
                 --api_server_ip ${api_address} \
                 --api_server_port ${api_port} \
                 --admin_user ${keystone_admin_user} \
                 --admin_password ${keystone_admin_password} \
                 --admin_tenant ${keystone_admin_tenant_name} \
                 --oper ${oper}",
  }
}
