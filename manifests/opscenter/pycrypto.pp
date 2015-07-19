# Class ::cassandra::opscenter::pycrypto
class cassandra::opscenter::pycrypto (
  $ensure       = 'present',
  $manage_epel  = false,
  $package_name = 'pycrypto',
  $reqd_pckgs   = ['python-devel', 'python-pip' ],
  $provider     = 'pip',
  ){
  if $::osfamily == 'RedHat' {
    if $manage_epel == true {
      package { 'epel-release':
        ensure => 'present',
        before => Package[ $reqd_pckgs ]
      }
    }

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
