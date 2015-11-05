# == Class: contrail::webui::install
#
# Install the webui service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for webui
#
class contrail::webui::install (
  $package_name = $contrail::webui::package_name,
) {

  package { $package_name :
    ensure => installed,
  }

}
