# == Class: contrail::vrouter::provision_vrouter
#
# Provision the vrouter
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
# [*node_address*]
#   (optional) IP address of the vrouter agent
#   Defaults to $::ipaddress
#
# [*node_name*]
#   (optional) Hostname of the vrouter agent
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
# [*oper*]
#   (optional) Operation to run (add|del)
#   Defaults to 'add'
#
class contrail::vrouter::provision_vrouter (
  $api_address                = '127.0.0.1',
  $api_port                   = 8082,
  $node_address               = $::ipaddress,
  $node_name                  = $::hostname,
  $keystone_admin_user        = 'admin',
  $keystone_admin_password    = 'password',
  $keystone_admin_tenant_name = 'admin',
  $oper                       = 'add',
) {

  exec { "provision_vrouter.py ${node_name}" :
    command => "python /opt/contrail/utils/provision_vrouter.py \
                 --host_name ${node_name} \
                 --host_ip ${node_address} \
                 --api_server_ip ${api_address} \
                 --api_server_port ${api_port} \
                 --admin_user ${keystone_admin_user} \
                 --admin_password ${keystone_admin_password} \
                 --admin_tenant ${keystone_admin_tenant_name} \
                 --oper ${oper}",
  }

}
