# ==define manila::backend::generic
#
# ===Parameters
# [*share_backend_name*]
#   (optional) Name of the backend in manila.conf that
#   these settings will reside in
#
# [*smb_template_config_path*]
#   (optional) Path to smb config.
#   Defaults to: $state_path/smb.conf
#
# [*volume_name_template*]
#   (optional) Volume name template.
#   Defaults to: manila-share-%s
#
# [*volume_snapshot_name_template*]
#   (optional) Volume snapshot name template.
#   Defaults to: manila-snapshot-%s
#
# [*share_mount_path*]
#   (optional) Parent path in service instance where shares will be mounted.
#   Defaults to: /shares
#
# [*max_time_to_create_volume*]
#   (optional) Maximum time to wait for creating cinder volume.
#   Defaults to: 180
#
# [*max_time_to_attach*]
#   (optional) Maximum time to wait for attaching cinder volume.
#   Defaults to: 120
#
# [*service_instance_smb_config_path*]
#   (optional) Path to smb config in service instance.
#   Defaults to: $share_mount_path/smb.conf
#
# [*share_volume_fstype*]
#   (optional) Filesystem type of the share volume.
#   Choices: 'ext4', 'ext3'
#   Defaults to: ext4
#
# [*share_helpers*]
#   (optional) Specify list of share export helpers.
#   Defaults to: ['CIFS=manila.share.drivers.generic.CIFSHelper',
#                'NFS=manila.share.drivers.generic.NFSHelper']
#
define manila::backend::generic (
  $share_backend_name               = $name,
  $smb_template_config_path         = '$state_path/smb.conf',
  $volume_name_template             = 'manila-share-%s',
  $volume_snapshot_name_template    = 'manila-snapshot-%s',
  $share_mount_path                 = '/shares',
  $max_time_to_create_volume        = 180,
  $max_time_to_attach               = 120,
  $service_instance_smb_config_path = '$share_mount_path/smb.conf',
  $share_volume_fstype              = 'ext4',
  $share_helpers = ['CIFS=manila.share.drivers.generic.CIFSHelper',
                    'NFS=manila.share.drivers.generic.NFSHelper'],
) {

  $share_driver = 'manila.share.drivers.generic.GenericShareDriver'

  manila_config {
    "${name}/share_backend_name":               value => $share_backend_name;
    "${name}/share_driver":                     value => $share_driver;
    "${name}/smb_template_config_path":         value => $smb_template_config_path;
    "${name}/volume_name_template":             value => $volume_name_template;
    "${name}/volume_snapshot_name_template":    value => $volume_snapshot_name_template;
    "${name}/share_mount_path":                 value => $share_mount_path;
    "${name}/max_time_to_create_volume":        value => $max_time_to_create_volume;
    "${name}/max_time_to_attach":               value => $max_time_to_attach;
    "${name}/service_instance_smb_config_path": value => $service_instance_smb_config_path;
    "${name}/share_volume_fstype":              value => $share_volume_fstype;
    "${name}/share_helpers":                    value => $share_helpers;
  }
}
