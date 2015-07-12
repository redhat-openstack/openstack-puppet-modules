# Please see the README file for the module.
class cassandra::java (
  $ensure       = 'present',
  $package_name = 'undef'
  ) {
  if $package_name == 'undef' {
    if $::osfamily == 'RedHat' {
      $java_package_name = 'java-1.8.0-openjdk-headless'
    } elsif $::operatingsystem == 'Ubuntu' {
      $java_package_name = 'openjdk-7-jre-headless'
    } else {
      fail("OS family ${::osfamily} not supported")
    }
  } else {
    $java_package_name = $package_name
  }

  package { $java_package_name:
    ensure => $ensure,
    before => Class['cassandra']
  }
}
