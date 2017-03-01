# == Class: contrail::control::install
#
# Install the control service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for control
#
class contrail::control::install (
  $package_name = $contrail::control::package_name,
) {

  package { $package_name :
    ensure => installed,
  }

}
