# == Define: pacemaker::new::resource::filesystem
#
# A resource type to create a pacemaker Filesystem resources, provided
# for convenience.
#
# === Parameters
#
# [*ensure*]
#   (optional) Whether to make the resource present or absent
#   Defaults to present
#
# [*device*]
#   (optional) The device which is being mounted
#   For example: 192.168.200.100:/export/foo
#   Default: undef
#
# [*directory*]
#   (optional) Where to mount the device (the empty dir must already exist)
#   Default: undef
#
# [*fstype*]
#   (optional) As you would pass to mount, for example 'nfs'
#   Default: undef
#
# [*fsoptions*]
#   (optional) Filesystem options as you would pass to mount command
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
define pacemaker::new::resource::filesystem (
  $ensure             = 'present',
  $device             = undef,
  $directory          = undef,
  $fstype             = undef,
  $fsoptions          = undef,
  $additional         = { },

  $metadata           = { },
  $operations         = { },
  $complex_type       = 'simple',
  $complex_metadata   = { },

  $primitive_class    = 'ocf',
  $primitive_provider = 'heartbeat',
  $primitive_type     = 'Filesystem',
) {

  validate_string($ensure)
  validate_string($device)
  validate_absolute_path($directory)

  validate_hash($metadata)
  validate_hash($operations)
  validate_string($complex_type)
  validate_hash($complex_metadata)

  validate_string($primitive_class)
  validate_string($primitive_provider)
  validate_string($primitive_type)

  $resource_id = regsubst("fs${device}", '\/', '_', 'G')

  $parameters = pacemaker_resource_parameters(
    'device', $device,
    'directory', $directory,
    'fstype', $fstype,
    'fsoptions', $fsoptions,
    $additional
  )

  pacemaker_resource { $resource_id :
    ensure             => $ensure,
    primitive_type     => $primitive_type,
    primitive_provider => $primitive_provider,
    primitive_class    => $primitive_class,
    parameters         => $parameters,
    metadata           => $metadata,
    operations         => $operations,
    complex_type       => $complex_type,
    complex_metadata   => $complex_metadata,
  }

}
