# Class: timezone::params
#
# Defines all the variables used in the module.
#
class timezone::params {
  case $::osfamily {
    'Debian': {
      $package = 'tzdata'
      $zoneinfo_dir = '/usr/share/zoneinfo/'
      $localtime_file = '/etc/localtime'
      $timezone_file = '/etc/timezone'
      $timezone_file_template = 'timezone/timezone.erb'
    }
    'RedHat': {
      $package = 'tzdata'
      $zoneinfo_dir = '/usr/share/zoneinfo/'
      $localtime_file = '/etc/localtime'
      $timezone_file = '/etc/sysconfig/clock'
      $timezone_file_template = 'timezone/clock.erb'
    }
    'Gentoo': {
      $package = 'sys-libs/timezone-data'
      $zoneinfo_dir = '/usr/share/zoneinfo/'
      $localtime_file = '/etc/localtime'
      $timezone_file = '/etc/timezone'
      $timezone_file_template = 'timezone/timezone.erb'
    }
    'Archlinux': {
      $package = 'tzdata'
      $zoneinfo_dir = '/usr/share/zoneinfo/'
      $localtime_file = '/etc/localtime'
      $timezone_file = false
    }
    'Suse': {
      $package = 'timezone'
      $zoneinfo_dir = '/usr/share/zoneinfo/'
      $localtime_file = '/etc/localtime'
      $timezone_file = false
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
