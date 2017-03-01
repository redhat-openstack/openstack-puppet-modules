# == Class: gnocchi
#
# Full description of class gnocchi here.
#
# === Parameters
#
# [*ensure_package*]
#   (optional) The state of gnocchi packages
#   Defaults to 'present'
#
# [*log_dir*]
#   (optional) Directory where logs should be stored.
#   If set to boolean false, it will not log to any directory.
#   Defaults to undef
#
# [*state_path*]
#   (optional) Directory for storing state.
#   Defaults to '/var/lib/gnocchi'
#
# [*lock_path*]
#   (optional) Directory for lock files.
#   On RHEL will be '/var/lib/gnocchi/tmp' and on Debian '/var/lock/gnocchi'
#   Defaults to $::gnocchi::params::lock_path
#
# [*verbose*]
#   (optional) Set log output to verbose output.
#   Defaults to undef
#
# [*debug*]
#   (optional) Set log output to debug output.
#   Defaults to undef
#
# [*use_syslog*]
#   (optional) Use syslog for logging
#   Defaults to undef
#
# [*use_stderr*]
#   (optional) Use stderr for logging
#   Defaults to undef
#
# [*log_facility*]
#   (optional) Syslog facility to receive log lines.
#   Defaults to undef
#
# [*database_connection*]
#   (optional) Connection url for the gnocchi database.
#   Defaults to undef.
#
class gnocchi (
  $ensure_package                     = 'present',
  $verbose                            = undef,
  $debug                              = undef,
  $use_syslog                         = undef,
  $use_stderr                         = undef,
  $log_facility                       = undef,
  $database_connection                = undef,
) inherits gnocchi::params {

  include ::gnocchi::db
  include ::gnocchi::logging

  package { 'gnocchi':
    ensure => $ensure_package,
    name   => $::gnocchi::params::common_package_name,
    tag    => ['openstack', 'gnocchi-package'],
  }

}
