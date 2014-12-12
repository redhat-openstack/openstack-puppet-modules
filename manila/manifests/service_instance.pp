# ==define manila::service_instance
#
# ===Parameters
# [*share_backend_name*]
#   (required) Name of the backend in manila.conf that
#   these settings will reside in
#
# [*service_image_name*]
#   (optional) Name of image in glance, that will be used to create
#    service instance.
#   Defaults to: 'manila-service-image'
#
# [*service_instance_name_template*]
#   (optional) Name of service instance.
#   Defaults to: 'manila_service_instance_%s'
#
# [*service_instance_user*]
#   (required) User in service instance.
#
# [*service_instance_password*]
#   (required) Password to service instance user.
#
# [*manila_service_keypair_name*]
#   (optional) Name of keypair that will be created and used
#    for service instance.
#   Defaults to: 'manila-service'
#
# [*path_to_public_key*]
#   (optional) Path to hosts public key.
#   Defaults to: '~/.ssh/id_rsa.pub'
#
# [*path_to_private_key*]
#   (optional) Path to hosts private key.
#   Defaults to: '~/.ssh/id_rsa'
#
# [*max_time_to_build_instance*]
#   (optional) Maximum time to wait for creating service instance.
#   Defaults to: 300
#
# [*service_instance_security_group*]
#   (optional) Name of security group, that will be used for
#    service instance creation.
#   Defaults to: 'manila-service'
#
# [*service_instance_flavor_id*]
#   (optional) ID of flavor, that will be used for service instance
#    creation.
#   Defaults to: 100
#
# [*service_network_name*]
#   (optional) Name of manila service network.
#   Defaults to: 'manila_service_network'
#
# [*service_network_cidr*]
#   (optional) CIDR of manila service network.
#   Defaults to: '10.254.0.0/16'
#
# [*service_network_division_mask*]
#   (optional) This mask is used for dividing service network into
#    subnets, IP capacity of subnet with this mask directly
#    defines possible amount of created service VMs
#    per tenant's subnet.
#   Defaults to: 28
#
# [*interface_driver*]
#   (optional) Vif driver.
#   Defaults to: 'manila.network.linux.interface.OVSInterfaceDriver'
#
# [*connect_share_server_to_tenant_network*]
#   (optional) Attach share server directly to smyhare network.
#   Defaults to: false

class manila::service_instance (
  $share_backend_name                     = $name,
  $service_image_name                     = 'manila-service-image',
  $service_instance_name_template         = 'manila_service_instance_%s',
  $service_instance_user                  = undef,
  $service_instance_password              = undef,
  $manila_service_keypair_name            = 'manila-service',
  $path_to_public_key                     = '~/.ssh/id_rsa.pub',
  $path_to_private_key                    = '~/.ssh/id_rsa',
  $max_time_to_build_instance             = 300,
  $service_instance_security_group        = 'manila-service',
  $service_instance_flavor_id             = 100,
  $service_network_name                   = 'manila_service_network',
  $service_network_cidr                   = '10.254.0.0/16',
  $service_network_division_mask          = 28,
  $interface_driver = 'manila.network.linux.interface.OVSInterfaceDriver',
  $connect_share_server_to_tenant_network = false,

) {

  manila_config {
    "${name}/share_backend_name":                     value => $share_backend_name;
    "${name}/service_image_name":                     value => $service_image_name;
    "${name}/service_instance_name_template":         value => $service_instance_name_template;
    "${name}/service_instance_user":                  value => $service_instance_user;
    "${name}/service_instance_password":              value => $service_instance_password;
    "${name}/manila_service_keypair_name":            value => $manila_service_keypair_name;
    "${name}/path_to_public_key":                     value => $path_to_public_key;
    "${name}/path_to_private_key":                    value => $path_to_private_key;
    "${name}/max_time_to_build_instance":             value => $max_time_to_build_instance;
    "${name}/service_instance_security_group":        value => $service_instance_security_group;
    "${name}/service_instance_flavor_id":             value => $service_instance_flavor_id;
    "${name}/service_network_name":                   value => $service_network_name;
    "${name}/service_network_cidr":                   value => $service_network_cidr;
    "${name}/service_network_division_mask":          value => $service_network_division_mask;
    "${name}/interface_driver":                       value => $interface_driver;
    "${name}/connect_share_server_to_tenant_network": value => $connect_share_server_to_tenant_network;
  }
}
