# == Class qdr::service
#
# This class is called from qdr for qdrouterd service management
class qdr::service inherits qdr {

  $service_enable   = $qdr::service_enable
  $service_ensure   = $qdr::service_ensure
  $service_name     = $qdr::service_name
  
  service { $service_name:
    ensure     => $service_ensure,
    enable     => $service_enable,
    hasstatus  => true,
    hasrestart => true,
  }
  
}
