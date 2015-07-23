#
# == Class: manila::ganesha
#
# Class to set NFS Ganesha options for share drivers
#
# === Parameters
# [*ganesha_config_dir*]
#   (required) Directory where Ganesha config files are stored.
#   Defaults to /etc/ganesha
#
# [*ganesha_config_path*]
#   (required) Path to main Ganesha config file.
#   Defaults to $ganesha_config_dir/ganesha.conf
#
# [*ganesha_service_name*]
#   (required) Name of the ganesha nfs service.
#   Defaults to ganesha.nfsd
#
# [*ganesha_db_path*]
#   (required) Location of Ganesha database file (Ganesha module only).
#   Defaults to $state_path/manila-ganesha.db
#
# [*ganesha_export_dir*]
#   (required) Path to directory containing Ganesha export configuration.
#   (Ganesha module only.)
#   Defaults to $ganesha_config_dir/export.d
#
# [*ganesha_export_template_dir*]
#   (required) Path to directory containing Ganesha export block templates.
#   (Ganesha module only.)
#   Defaults to /etc/manila/ganesha-export-templ.d
#
class manila::ganesha (
  $ganesha_config_dir          = '/etc/ganesha',
  $ganesha_config_path         = '/etc/ganesha/ganesha.conf',
  $ganesha_service_name        = 'ganesha.nfsd',
  $ganesha_db_path             = '$state_path/manila-ganesha.db',
  $ganesha_export_dir          = '/etc/ganesha/export.d',
  $ganesha_export_template_dir = '/etc/manila/ganesha-export-templ.d',
) {

  manila_config {
    'DEFAULT/ganesha_config_dir':          value => $ganesha_config_dir;
    'DEFAULT/ganesha_config_path':         value => $ganesha_config_path;
    'DEFAULT/ganesha_service_name':        value => $ganesha_service_name;
    'DEFAULT/ganesha_db_path':             value => $ganesha_db_path;
    'DEFAULT/ganesha_export_dir':          value => $ganesha_export_dir;
    'DEFAULT/ganesha_export_template_dir': value => $ganesha_export_template_dir;
  }

  if ($::osfamily == 'RedHat') {
    package { 'nfs-ganesha':
      ensure => present
    }
  } else {
    warning("Unsupported osfamily ${::osfamily}, Red Hat is the only supported platform.")
  }
}
