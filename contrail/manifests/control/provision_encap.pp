# == Class: contrail::control::provision_encap
#
# Provision encap
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
# [*encap_priority*]
#   (optional) Encapsulation priority
#   Defaults 'MPLSoUDP,MPLSoGRGE,VXLAN'
#
# [*vxlan_vn_id_mode*]
#   (optional) VxLAN VN id mode
#   Defaults to 'automatic'
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
class contrail::control::provision_encap (
  $api_address                = '127.0.0.1',
  $api_port                   = 8082,
  $encap_priority             = 'MPLSoUDP,MPLSoGRE,VXLAN',
  $vxlan_vn_id_mode           = 'automatic',
  $keystone_admin_user        = 'admin',
  $keystone_admin_password    = 'password',
  $keystone_admin_tenant_name = 'admin',
  $oper                       = 'add',
) {

  exec { "provision_encap.py ${api_address}" :
    command => "python /opt/contrail/utils/provision_encap.py \
                 --api_server_ip ${api_address} \
                 --api_server_port ${api_port} \
                 --encap_priority ${encap_priority} \
                 --vxlan_vn_id_mode ${vxlan_vn_id_mode} \
                 --admin_user ${keystone_admin_user} \
                 --admin_password ${keystone_admin_password} \
                 --oper ${oper}",
  }

}
