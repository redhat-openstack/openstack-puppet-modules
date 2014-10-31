class pacemaker::params {

  $hacluster_pwd         = 'CHANGEME'
  case $::osfamily {
    redhat: {
      $package_list = ["pacemaker", "pcs", "cman"]
      $service_name = 'pacemaker'
    }
    default: {
      case $::operatingsystem {
        default: {
          fail("Unsupported platform: ${::osfamily}/${::operatingsystem}")
        }
      }
    }
  }
}
