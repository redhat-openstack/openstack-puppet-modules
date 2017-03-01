# == Define Resource Type: pacemaker::resource::ocf
#
# A resource type to create pacemaker ocf resources, provided for
# convenience.
#
# === Parameters
#
# [*name*]
# The name of the pacemaker resource, i.e. as seen in "pcs status".
#
# [*ocf_agent_name*]
# The name of the ocf resource agent.  Optional.  Defaults to *name*.
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
# [*master_params*]
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
define pacemaker::resource::ocf(
  $ensure             = 'present',
  $ocf_agent_name     = $name,
  $resource_params    = '',
  $meta_params        = '',
  $op_params          = '',
  $clone_params       = undef,
  $group_params       = undef,
  $master_params      = undef,
  $post_success_sleep = 0,
  $tries              = 1,
  $try_sleep          = 0,
) {
  pcmk_resource { $name:
    ensure             => $ensure,
    resource_type      => "ocf:${ocf_agent_name}",
    resource_params    => $resource_params,
    meta_params        => $meta_params,
    op_params          => $op_params,
    clone_params       => $clone_params,
    group_params       => $group_params,
    master_params      => $master_params,
    post_success_sleep => $post_success_sleep,
    tries              => $tries,
    try_sleep          => $try_sleep,
  }
}
