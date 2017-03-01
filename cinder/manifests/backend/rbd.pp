# == define: cinder::backend::rbd
#
# Setup Cinder to use the RBD driver.
# Compatible for multiple backends
#
# === Parameters
#
# [*rbd_pool*]
#   (required) Specifies the pool name for the block device driver.
#
# [*rbd_user*]
#   (required) A required parameter to configure OS init scripts and cephx.
#
# [*backend_host*]
#   (optional) Allows specifying the hostname/key used for the owner of volumes
#   created.  This must be set to the same value on all nodes in a multi-node
#   environment.
#   Defaults to 'rbd:<rbd_pool>'
#
# [*volume_backend_name*]
#   (optional) Allows for the volume_backend_name to be separate of $name.
#   Defaults to: $name
#
# [*rbd_ceph_conf*]
#   (optional) Path to the ceph configuration file to use
#   Defaults to '/etc/ceph/ceph.conf'
#
# [*rbd_flatten_volume_from_snapshot*]
#   (optional) Enable flatten volumes created from snapshots.
#   Defaults to false
#
# [*rbd_secret_uuid*]
#   (optional) A required parameter to use cephx.
#   Defaults to $::os_service_default
#
# [*volume_tmp_dir*]
#   (optional) Location to store temporary image files if the volume
#   driver does not write them directly to the volume
#   Defaults to $::os_service_default
#
# [*rbd_max_clone_depth*]
#   (optional) Maximum number of nested clones that can be taken of a
#   volume before enforcing a flatten prior to next clone.
#   A value of zero disables cloning
#   Defaults to '5'
#
# [*extra_options*]
#   (optional) Hash of extra options to pass to the backend stanza
#   Defaults to: {}
#   Example :
#     { 'rbd_backend/param1' => { 'value' => value1 } }
#
define cinder::backend::rbd (
  $rbd_pool,
  $rbd_user,
  $backend_host                     = undef,
  $volume_backend_name              = $name,
  $rbd_ceph_conf                    = '/etc/ceph/ceph.conf',
  $rbd_flatten_volume_from_snapshot = false,
  $rbd_secret_uuid                  = $::os_service_default,
  $volume_tmp_dir                   = $::os_service_default,
  $rbd_max_clone_depth              = '5',
  $extra_options                    = {},
) {

  include ::cinder::params

  cinder_config {
    "${name}/volume_backend_name":              value => $volume_backend_name;
    "${name}/volume_driver":                    value => 'cinder.volume.drivers.rbd.RBDDriver';
    "${name}/rbd_ceph_conf":                    value => $rbd_ceph_conf;
    "${name}/rbd_user":                         value => $rbd_user;
    "${name}/rbd_pool":                         value => $rbd_pool;
    "${name}/rbd_max_clone_depth":              value => $rbd_max_clone_depth;
    "${name}/rbd_flatten_volume_from_snapshot": value => $rbd_flatten_volume_from_snapshot;
    "${name}/rbd_secret_uuid":                  value => $rbd_secret_uuid;
    "${name}/volume_tmp_dir":                   value => $volume_tmp_dir;
  }

  if $backend_host {
    cinder_config {
      "${name}/backend_host": value => $backend_host;
    }
  } else {
    cinder_config {
      "${name}/backend_host": value => "rbd:${rbd_pool}";
    }
  }

  create_resources('cinder_config', $extra_options)

  case $::osfamily {
    'Debian': {
      $override_line    = "env CEPH_ARGS=\"--id ${rbd_user}\""
      $override_match   = '^env CEPH_ARGS='
    }
    'RedHat': {
      $override_line    = "export CEPH_ARGS=\"--id ${rbd_user}\""
      $override_match   = '^export CEPH_ARGS='
    }
    default: {
      fail("unsupported osfamily ${::osfamily}, currently Debian and Redhat are the only supported platforms")
    }
  }

  # Creates an empty file if it doesn't yet exist
  ensure_resource('file', $::cinder::params::ceph_init_override, {'ensure' => 'present'})

  ensure_resource('file_line', 'set initscript env', {
    line   => $override_line,
    path   => $::cinder::params::ceph_init_override,
    match  => $override_match,
    notify => Service['cinder-volume']
  })

}
