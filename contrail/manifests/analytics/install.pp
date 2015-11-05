# == Class: contrail::analytics::install
#
# Install the analytics service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for analytics
#
class contrail::analytics::install (
  $package_name = $contrail::analytics::package_name,
) {

  package { $package_name :
    ensure => installed,
  }

}
