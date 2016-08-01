# ovn params
# == Class: ovn::params
#
# This class defines the variable like
#
class ovn::params {
  include ::openstacklib::defaults
    case $::osfamily {
      'Redhat': {
          $ovn_northd_package_name        = 'openvswitch-ovn-central'
          $ovn_controller_package_name    = 'openvswitch-ovn-host'
          $ovn_northd_service_name        = 'ovn-northd'
          $ovn_northd_service_status      = true
          $ovn_northd_service_pattern     = undef
          $ovn_controller_service_name    = 'ovn-controller'
          $ovn_controller_service_status  = true
          $ovn_controller_service_pattern = undef
      }
      'Debian': {
          $ovn_northd_package_name        = 'ovn-central'
          $ovn_controller_package_name    = 'ovn-host'
          $ovn_northd_service_name        = 'ovn-central'
          $ovn_northd_service_status      = false # status broken in UCA
          $ovn_northd_service_pattern     = 'ovn-northd'
          $ovn_controller_service_name    = 'ovn-host'
          $ovn_controller_service_status  = false # status broken in UCA
          $ovn_controller_service_pattern = 'ovn-controller'
      }
      default: {
        fail " Osfamily ${::osfamily} not supported yet"
      }
    }
}
