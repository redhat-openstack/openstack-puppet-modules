# == Define Resource Type: pacemaker::resource::service
#
# A resource type to create pacemaker lsb or systemd resources
# (depending on distro), provided for convenience.
#
# === Parameters
#
# [*name*]
# The name of the pacemaker resource, i.e. as seen in "pcs status".
#
# [*service_name*]
# The name of the systemd or lsb service.  Optional.  Defaults to *name*.
#
# [*resource_params*]
# Additional resource parameters to pass to "pcs create".  Optional.
#
# [*op_params*]
# Additional op parameters to pass to "pcs create".  Optional.
#
# [*meta_params*]
# Additional meta parameters to pass to "pcs create".  Optional.
#
# [*clone_params*]
# Additional clone parameters to pass to "pcs create".  Use '' or true
# for to pass --clone to "pcs resource create" with no addtional clone
# parameters.  Optional.
#
# [*group_params*]
# Additional group parameters to pass to "pcs create", typically just
# the the name of the pacemaker resource group. Optional.
#
define pacemaker::resource::service(
  $ensure             = 'present',
  $service_name       = $name,
  $resource_params    = '',
  $meta_params        = '',
  $op_params          = '',
  $clone_params       = undef,
  $group_params       = undef,
  $post_success_sleep = 0,
  $tries              = 1,
  $try_sleep          = 0,
) {
  include ::pacemaker::params
  $res = "pacemaker::resource::${::pacemaker::params::services_manager}"

  create_resources($res,
    { "${name}" => {
      ensure             => $ensure,
      service_name       => $service_name,
      resource_params    => $resource_params,
      meta_params        => $meta_params,
      op_params          => $op_params,
      clone_params       => $clone_params,
      group_params       => $group_params,
      post_success_sleep => $post_success_sleep,
      tries              => $tries,
      try_sleep          => $try_sleep,
    }
  })
}
