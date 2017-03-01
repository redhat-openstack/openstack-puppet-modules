# == Class: contrail::config::install
#
# Install the config service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for config
#
class contrail::config::install (
  $package_name = $contrail::config::package_name,
) {

  package { $package_name :
    ensure => installed,
  }

}
