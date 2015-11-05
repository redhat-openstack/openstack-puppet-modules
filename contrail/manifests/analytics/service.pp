# == Class: contrail::analytics::service
#
# Manage the analytics service
#
class contrail::analytics::service {

  service {'supervisor-analytics' :
    ensure => running,
    enable => true,
  }

}
