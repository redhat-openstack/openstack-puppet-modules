# Class ::cassandra::opscenter::pycrypto
#
# Please see the README for the module for details on usage.
class cassandra::opscenter::pycrypto (
  $ensure       = 'present',
  $manage_epel  = false,
  $package_name = 'pycrypto',
  $provider     = 'pip',
  $reqd_pckgs   = ['python-devel', 'python-pip' ],
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

    ##########################################################################
    # Nasty hack to workaround PUP-3829.  Hopefully can be removed in the
    # not too distant future.
    file { '/usr/bin/pip-python':
      ensure  => 'link',
      target  => '/usr/bin/pip',
      require => Package['python-pip'],
      before  => Package[$package_name]
    }
    # End of PUP-3829 hack.
    ##########################################################################

    package { $package_name:
      ensure   => $ensure,
      provider => $provider,
      before   => Package['opscenter']
    }
  }
}
