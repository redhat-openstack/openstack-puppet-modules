# == Class uchiwa::service
#
# This class is meant to be called from uchiwa
# It ensure the service is running
#
class uchiwa::service {

  if $uchiwa::manage_services == true {
    service { $uchiwa::service_name:
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
    }
  }
}
