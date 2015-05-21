# == Define Resource Type: pacemaker::resource::filesystem
#
# A resource type to create pacemaker Filesystem resources, provided
# for convenience.
#
# === Parameters
#
# [*name*]
# The name of the pacemaker resource, i.e. as seen in "pcs status".
#
# [*device*]
# The device which is being mounted.  E.g. 192.168.200.100:/export/foo.
#
# [*directory*]
# Where to mount the device (the empty dir must already exist).
#
# [*fstype*]
# As you would pass to mount.  E.g., nfs.
#
# [*meta_params*]
# Additional meta parameters to pass to "pcs create".  Optional.
#
# [*op_params*]
# Additional op parameters to pass to "pcs create".  Optional.
#
# [*clone_params*]
# Additional clone parameters to pass to "pcs create".  Use '' or true
# for to pass --clone to "pcs resource create" with no addtional clone
# parameters.  Optional.
#
# [*group_params*]
# Additional group parameters to pass to "pcs create", typically just
# the the name of the pacemaker resource group. Optional.

define pacemaker::resource::filesystem(
  $ensure             = 'present',
  $device             = '',
  $directory          = '',
  $fsoptions          = '',
  $fstype             = '',
  $meta_params        = undef,
  $op_params          = '',
  $clone_params       = undef,
  $group_params       = undef,
  $post_success_sleep = 0,
  $tries              = 1,
  $try_sleep          = 0,
) {
  $resource_id = delete("fs-${directory}", '/')

  $resource_params = $fsoptions ? {
    ''      => "device=${device} directory=${directory} fstype=${fstype}",
    default => "device=${device} directory=${directory} fstype=${fstype} options=\"${fsoptions}\"",
  }

  pcmk_resource { $resource_id:
    ensure             => $ensure,
    resource_type      => 'Filesystem',
    resource_params    => $resource_params,
    meta_params        => $meta_params,
    op_params          => $op_params,
    clone_params       => $clone_params,
    group_params       => $group_params,
    post_success_sleep => $post_success_sleep,
    tries              => $tries,
    try_sleep          => $try_sleep,
  }
}
