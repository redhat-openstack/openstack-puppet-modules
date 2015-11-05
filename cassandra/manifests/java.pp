# Please see the README file for the module.
class cassandra::java (
  $ensure           = 'present',
  $jna_ensure       = 'present',
  $jna_package_name = undef,
  $package_name     = undef
  ) {
  if $package_name == undef {
    if $::osfamily == 'RedHat' {
      $java_package_name = 'java-1.8.0-openjdk-headless'
    } elsif $::osfamily == 'Debian' {
      $java_package_name = 'openjdk-7-jre-headless'
    } else {
      fail("OS family ${::osfamily} not supported")
    }
  } else {
    $java_package_name = $package_name
  }

  if $jna_package_name == undef {
    if $::osfamily == 'RedHat' {
      $jna = 'jna'
    } elsif $::osfamily == 'Debian' {
      $jna = 'libjna-java'
    } else {
      fail("OS family ${::osfamily} not supported")
    }
  } else {
    $jna = $jna_package_name
  }

  package { $java_package_name:
    ensure => $ensure,
  }

  package { $jna:
    ensure => $jna_ensure,
  }
}
