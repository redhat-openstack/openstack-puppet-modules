# == Define: pacemaker::new::resource::ip
#
# A resource type to create a pacemaker IPaddr2 resources, provided
# for convenience.
#
# === Parameters
#
# [*ip_address*]
#   The virtual IP address you want pacemaker to create and manage
#
# [*ensure*]
#   (optional) Whether to make sure resource is created or removed
#   Defaults to present
#
# [*cidr_netmask*]
#   (optional) The netmask to use in the cidr= option in the
#   "pcs resource create"command
#   Defaults to '32'
#
# [*nic*]
#   (optional) The nic to use in the nic= option in the "pcs resource create"
#   command
#   Defaults to undef
#
# [*additional*]
#   (optional) Add any additional resource parameters as a hash.
#   Default: {}
#
# [*metadata*]
#   (optional) Additional meta parameters
#   Default: {}
#
# [*operations*]
#   (optional) Additional op parameters
#   Default: {}
#
# [*primitive_class*]
#   Default: 'ocf'
#
# [*primitive_provider*]
#   Default: 'heartbeat'
#
# [*primitive_type*]
#   Default: 'IPaddr2'
#
define pacemaker::new::resource::ip (
  $ensure             = 'present',
  $ip_address         = undef,
  $cidr_netmask       = '32',
  $nic                = undef,
  $additional         = { },

  $metadata           = { },
  $operations         = { },

  $primitive_class    = 'ocf',
  $primitive_provider = 'heartbeat',
  $primitive_type     = 'IPaddr2',
) {
  validate_string($ensure)
  validate_ip_address($ip_address)
  validate_integer($cidr_netmask)
  validate_string($nic)
  validate_hash($additional)

  validate_hash($metadata)
  validate_hash($operations)

  validate_string($primitive_class)
  validate_string($primitive_provider)
  validate_string($primitive_type)

  $resource_name = regsubst($ip_address, '(:)', '.', 'G')

  $parameters = pacemaker_resource_parameters(
    'ip', $ip_address,
    'cidr_netmask', $cidr_netmask,
    'nic', $nic,
    $additional
  )

  pacemaker_resource { "ip-${resource_name}":
    ensure             => $ensure,
    primitive_type     => $primitive_type,
    primitive_provider => $primitive_provider,
    primitive_class    => $primitive_class,
    parameters         => $parameters,
    metadata           => $metadata,
    operations         => $operations,
  }
}
