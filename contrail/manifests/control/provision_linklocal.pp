# == Class: contrail::control::provision_linklocal
#
# Provision the metadata service
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
# [*linklocal_service_name*]
#   (optional) Metadata service name
#   Defaults to 'metadata'
#
# [*linklocal_service_ip*]
#   (optional) IP address of the metadata service
#   Defaults to '169.254.169.254'
#
# [*linklocal_service_port*]
#   (optional) Port of the metadata service
#   Defaults to 80
#
# [*ipfabric_service_ip*]
#   (optional) IP of the ipfabric
#   Defaults to '127.0.0.1'
#
# [*ipfabric_service_port*]
#   (optional) Port of the ipfabric
#   Defaults to 8775
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
class contrail::control::provision_linklocal (
  $api_address                = '127.0.0.1',
  $api_port                   = 8082,
  $linklocal_service_name     = 'metadata',
  $linklocal_service_ip       = '169.254.169.254',
  $linklocal_service_port     = 80,
  $ipfabric_service_ip        = '127.0.0.1',
  $ipfabric_service_port      = 8775,
  $keystone_admin_user        = 'admin',
  $keystone_admin_password    = 'password',
  $keystone_admin_tenant_name = 'admin',
  $oper                       = 'add',
) {

  exec { "provision_linklocal.py ${api_address}" :
    command => "python /opt/contrail/utils/provision_linklocal.py \
                 --api_server_ip ${api_address} \
                 --api_server_port ${api_port} \
                 --linklocal_service_name ${linklocal_service_name} \
                 --linklocal_service_ip ${linklocal_service_ip} \
                 --linklocal_service_port ${linklocal_service_port} \
                 --ipfabric_service_ip ${ipfabric_service_ip} \
                 --ipfabric_service_port ${ipfabric_service_port} \
                 --admin_user ${keystone_admin_user} \
                 --admin_password ${keystone_admin_password} \
                 --admin_tenant ${keystone_admin_tenant_name} \
                 --oper ${oper}",
  }

}
