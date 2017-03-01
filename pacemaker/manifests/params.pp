class pacemaker::params {

  $hacluster_pwd         = 'CHANGEME'
  case $::osfamily {
    redhat: {
      if $::operatingsystemrelease =~ /^6\..*$/ {
        $package_list = ["pacemaker","pcs","fence-agents","cman"]
        # TODO in el6.6, $pcsd_mode should be true
        $pcsd_mode = false
        $services_manager = 'lsb'
      } else {
        $package_list = ["pacemaker","pcs","fence-agents-all"]
        $pcsd_mode = true
        $services_manager = 'systemd'
      }
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
