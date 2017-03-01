# vswitch params
#
class vswitch::params {
  case $::osfamily {
    'Redhat': {
      $ovs_package_name      = 'openvswitch'
      $ovs_dkms_package_name = undef
      $ovs_service_name      = 'openvswitch'
      $provider              = 'ovs_redhat'
    }
    'Debian': {
      $ovs_package_name      = 'openvswitch-switch'
      $ovs_dkms_package_name = 'openvswitch-datapath-dkms'
      $ovs_service_name      = 'openvswitch-switch'
      $provider              = 'ovs'
    }
    'FreeBSD': {
      $ovs_package_name      = 'openvswitch'
      $ovs_pkg_provider      = 'pkgng'
      $provider              = 'ovs'
      $ovs_service_name      = 'ovs-vswitchd'
      $ovsdb_service_name    = 'ovsdb-server'
      $ovs_status            = "/usr/sbin/service ${ovs_service_name} onestatus"
      $ovsdb_status          = "/usr/sbin/service ${ovsdb_service_name} onestatus"
    }
    default: {
      fail " Osfamily ${::osfamily} not supported yet"
    }
  } # Case $::osfamily
}
