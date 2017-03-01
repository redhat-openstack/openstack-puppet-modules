# == Class: contrail::vrouter::service
#
# Manage the vrouter service
#
class contrail::vrouter::service {

  service {'supervisor-vrouter' :
    ensure => running,
    enable => true,
  }

}
