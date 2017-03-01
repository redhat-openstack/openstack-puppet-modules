# == Class: contrail::database::service
#
# Manage the database service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for database
#
class contrail::database::service {

  service {'supervisor-database' :
    ensure => running,
    enable => true,
  }

}
