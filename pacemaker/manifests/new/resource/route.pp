# == Define: pacemaker::new::resource::route
#
# A resource type to create a pacemaker Route resources, provided
# for convenience.
#
# === Parameters:
#
# [*ensure*]
#   (optional) Whether to make sure the constraint is present or absent
#   Defaults to present
#
# [*source*]
#   (optional) Route source
#   Default: undef
#
# [*destination*]
#   (optional) Route destination
#   Default: undef
#
# [*gateway*]
#   (optional) Gateway to use
#   Default: undef
#
# [*device*]
#   (optional) Network interface to use
#   Default: undef
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
# [*complex_type*]
#   Should a simple of comple primitive be created? (simple/clone/master)
#   Default: simple
#
# [*complex_metadata*]
#   Path additional complex type attributes
#   Default: {}
#
# [*primitive_class*]
#   Default: 'ocf'
#
# [*primitive_provider*]
#   Default: 'heartbeat'
#
# [*primitive_type*]
#   Default: 'Filesystem'
#
define pacemaker::new::resource::route (
  $ensure             = 'present',
  $device             = undef,
  $source             = undef,
  $destination        = undef,
  $gateway            = undef,
  $additional         = { },

  $operations         = { },
  $metadata           = { },

  $primitive_class    = 'ocf',
  $primitive_provider = 'heartbeat',
  $primitive_type     = 'Route',
) {

  validate_string($ensure)

  validate_hash($additional)
  validate_hash($metadata)
  validate_hash($operations)

  validate_string($primitive_class)
  validate_string($primitive_provider)
  validate_string($primitive_type)

  $parameters = pacemaker_resource_parameters(
    'device', $device,
    'source', $source,
    'destination', $destination,
    'gateway', $gateway,
    $additional
  )

  pacemaker_resource { "route-${name}":
    ensure             => $ensure,
    primitive_type     => $primitive_type,
    primitive_provider => $primitive_provider,
    primitive_class    => $primitive_class,
    parameters         => $parameters,
    metadata           => $metadata,
    operations         => $operations,
  }

}
