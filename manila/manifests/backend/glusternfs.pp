#
# == Class: manila::backend::glusternfs
#
# Configures Manila to use GlusteFS NFS (Ganesha/GlusterNFS) as a share driver
#
# === Parameters
# [*glusterfs_target*]
#   (required) Specifies the GlusterFS volume to be mounted on the Manila host.
#   It is of the form [remoteuser@]<volserver>:<volid>.
#
# [*glusterfs_mount_point_base*]
#   (required) Base directory containing mount points for Gluster volumes.
#   Default: /mnt
#
# [*glusterfs_nfs_server_type*]
#   (optional) Type of NFS server that mediate access to the Gluster volumes
#   (Gluster or Ganesha).
#   Default: Gluster
#
# [*glusterfs_native_path_to_private_key*]
#   (optional) Path of Manila host's private SSH key file.
#
# [*glusterfs_ganesha_server_ip*]
#   (optional) Remote Ganesha server node's IP address.
#

define manila::backend::glusternfs (
  $share_backend_name                   = $name,
  $glusterfs_target,
  $glusterfs_mount_point_base,
  $glusterfs_nfs_server_type,
  $glusterfs_path_to_private_key,
  $glusterfs_ganesha_server_ip,
) {

  $share_driver = 'manila.share.drivers.glusterfs.GlusterfsShareDriver'

  manila_config {
    "${name}/share_backend_name":                       value => $share_backend_name;
    "${name}/share_driver":                             value => $share_driver;
    "${name}/glusterfs_target":                         value => $glusterfs_target;
    "${name}/glusterfs_mount_point_base":               value => $glusterfs_mount_point_base;
    "${name}/glusterfs_nfs_server_type":                value => $glusterfs_nfs_server_type;
    "${name}/glusterfs_path_to_private_key":            value => $glusterfs_path_to_private_key;
    "${name}/glusterfs_ganesha_server_ip":              value => $glusterfs_nfs_server_ip;
  }
  package { 'glusterfs': ensure => present }
  package { 'glusterfs-fuse': ensure => present }
}
