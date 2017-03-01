#
# == Class: manila::backend::glusternative
#
# Configures Manila to use GlusterFS native as a share driver
#
# === Parameters
# [*share_backend_name*]
#   (optional) Name of the backend in manila.conf that
#   these settings will reside in
#
# [*glusterfs_servers*]
#   (required) List of GlusterFS servers that can be used to create shares.
#   Each GlusterFS server should be of the form [remoteuser@]<volserver>, and
#   they are assumed to belong to distinct Gluster clusters.
#
# [*glusterfs_native_path_to_private_key*]
#   (optional) Path of Manila host's private SSH key file.
#
# [*glusterfs_volume_pattern*]
#   (optional) Regular expression template used to filter GlusterFS volumes for
#   share creation.
#
#
define manila::backend::glusternative (
  $share_backend_name                   = $name,
  $glusterfs_servers,
  $glusterfs_native_path_to_private_key,
  $glusterfs_volume_pattern,
) {

  $share_driver = 'manila.share.drivers.glusterfs_native.GlusterfsNativeShareDriver'

  manila_config {
    "${name}/share_backend_name":                       value => $share_backend_name;
    "${name}/share_driver":                             value => $share_driver;
    "${name}/glusterfs_servers":                        value => $glusterfs_servers;
    "${name}/glusterfs_native_path_to_private_key":     value => $glusterfs_native_path_to_private_key;
    "${name}/glusterfs_volume_pattern":                 value => $glusterfs_volume_pattern;
  }
  package { 'glusterfs': ensure => present }
  package { 'glusterfs-fuse': ensure => present }
}
