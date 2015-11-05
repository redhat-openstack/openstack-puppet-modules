# == Class: contrail::config::service
#
# Manage the config service
#
class contrail::config::service {

  service {'supervisor-config' :
    ensure => running,
    enable => true,
  }

}

