# Class ::cassandra::opscenter::pycrypto
class cassandra::opscenter::pycrypto (
  $ensure       = 'present',
  $package_name = 'pycrypto',
  $reqd_pckgs   = ['python-devel', 'python-pip' ],
  $provider     = 'pip',
  ){
  if $::osfamily == 'RedHat' {
    package { $reqd_pckgs:
      ensure => present,
      before => Package[$package_name]
    }

    package { $package_name:
      ensure   => $ensure,
      provider => $provider,
    }
  }
}
