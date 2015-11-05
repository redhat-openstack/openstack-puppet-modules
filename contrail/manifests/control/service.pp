# == Class: contrail::control::service
#
# Manage the control service
#
class contrail::control::service {

  service {'supervisor-control' :
    ensure => running,
    enable => true,
  }

}
