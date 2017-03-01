#
# == Class: manila::share::glusterfs
#
# Configures Manila to use GlusterFS as a share driver
#
# === Parameters
#
# [*glusterfs_volumes_config*]
#   (required) File with the list of Gluster volumes that can
#   be used to create shares
#
# [*glusterfs_mount_point_base*]
#   Base dir containing mount points for Gluster volumes.
#
# === Examples
#
# class { 'manila::share::glusterfs':
#   glusterfs_shares = ['192.168.1.1:/shares'],
# }
#
class manila::share::glusterfs (
  $glusterfs_volumes_config   = '/etc/manila/glusterfs_volumes',
  $glusterfs_mount_point_base = '$state_path/mnt',
) {

  manila::backend::glusterfs { 'DEFAULT':
    glusterfs_volumes_config   => $glusterfs_volumes_config,
    glusterfs_mount_point_base => $glusterfs_mount_point_base,
  }
}
