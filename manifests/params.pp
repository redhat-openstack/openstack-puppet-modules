class timezone::params {
  case $::osfamily {
    'Debian', 'RedHat': {
      $package = 'tzdata'
      $zoneinfo_dir = '/usr/share/zoneinfo/'
      $config_file = '/etc/localtime'
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
