#
# == define: manila::backend::glusternfs
#
# Configures Manila to use GlusteFS NFS (Ganesha/GlusterNFS) as a share driver
#
# Currently Red Hat is the only supported platform, due to lack of packages
# other platforms are not yet supported.
#
# === Parameters
# [*glusterfs_target*]
#   (required) Specifies the GlusterFS volume to be mounted on the Manila host.
#   It is of the form [remoteuser@]<volserver>:/<volid>.
#
# [*glusterfs_mount_point_base*]
#   (required) Base directory containing mount points for Gluster volumes.
#
# [*glusterfs_nfs_server_type*]
#   (required) Type of NFS server that mediate access to the Gluster volumes
#   (Gluster or Ganesha).
#   Default: Gluster
#
# [*glusterfs_path_to_private_key*]
#   (required) Path of Manila host's private SSH key file.
#
# [*glusterfs_ganesha_server_ip*]
#   (required) Remote Ganesha server node's IP address.
#
# [*share_backend_name*]
#   (optional) Backend name in manila.conf where these settings will reside in.
#
# [*package_ensure*]
#   (optional) Ensure state for package. Defaults to 'present'.
#

define manila::backend::glusternfs (
  $glusterfs_target,
  $glusterfs_mount_point_base,
  $glusterfs_nfs_server_type,
  $glusterfs_path_to_private_key,
  $glusterfs_ganesha_server_ip,
  $share_backend_name = $name,
  $package_ensure     = 'present',
) {

  include ::manila::params

  $share_driver = 'manila.share.drivers.glusterfs.GlusterfsShareDriver'

  manila_config {
    "${share_backend_name}/share_backend_name":            value => $share_backend_name;
    "${share_backend_name}/share_driver":                  value => $share_driver;
    "${share_backend_name}/glusterfs_target":              value => $glusterfs_target;
    "${share_backend_name}/glusterfs_mount_point_base":    value => $glusterfs_mount_point_base;
    "${share_backend_name}/glusterfs_nfs_server_type":     value => $glusterfs_nfs_server_type;
    "${share_backend_name}/glusterfs_path_to_private_key": value => $glusterfs_path_to_private_key;
    "${share_backend_name}/glusterfs_ganesha_server_ip":   value => $glusterfs_ganesha_server_ip;
  }

  package { $::manila::params::gluster_package_name:
    ensure => $package_ensure,
  }
  package { $::manila::params::gluster_client_package_name:
    ensure => $package_ensure,
  }
}
