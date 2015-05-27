# == Define Resource Type: pacemaker::resource::lsb
#
# See pacemaker::resource::service.  Typical usage is to declare
# pacemaker::resource::service rather than this resource directly.
#
define pacemaker::resource::lsb(
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
  pcmk_resource { $name:
    ensure             => $ensure,
    resource_type      => "lsb:${service_name}",
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
