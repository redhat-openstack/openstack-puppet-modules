# Please see the README file for the module.
class cassandra::optutils (
  $ensure       = 'present',
  $package_name = 'undef'
  ) {
  if $package_name == 'undef' {
    if $::osfamily == 'RedHat' {
      $real_package_name = 'cassandra22-tools'
    } elsif $::operatingsystem == 'Ubuntu' {
      $real_package_name = 'cassandra-tools'
    } else {
      fail("OS family ${::osfamily} not supported")
    }
  } else {
    $real_package_name = $package_name
  }

  package { $real_package_name:
    ensure  => $ensure,
    require => Class['cassandra']
  }
}
