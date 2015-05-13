#
# ZooKeeper installation on Debian
class zookeeper::os::debian(
  $ensure            = present,
  $snap_retain_count = 3,
  $cleanup_sh        = '/usr/lib/zookeeper/bin/zkCleanup.sh',
  $datastore         = '/var/lib/zookeeper',
  $user              = 'zookeeper',
  $start_with        = 'init.d',
  $ensure_cron       = true,
  # cloudera package is called zookeeper-server
  $service_package   = 'zookeeperd',
  $packages          = ['zookeeper'],
  $install_java      = false,
  $java_package      = undef
) {

  validate_bool($install_java)

  # if $install_java, try to make sure a JDK package is installed
  if ($install_java){
    if !$java_package {
      fail ( 'Java installation is required, but no java package was provided.' )
    }

    validate_string($java_package)

    # make sure the Java package is only installed once.
    anchor { 'zookeeper::os::debian::java': }

    # parameter allow_virtual is not supported before Puppet 3.6
    if versioncmp($::puppetversion, '3.6.0') >= 0 {
      ensure_resource('package', $java_package,
        {'ensure' => $ensure, 'allow_virtual' => true,
        'before' => Anchor['zookeeper::os::debian::java']}
      )
    } else {
      ensure_resource('package', $java_package,
        {'ensure' => $ensure,
        'before' => Anchor['zookeeper::os::debian::java']}
      )
    }

    ensure_resource('package', $packages,
      {'ensure' => $ensure, 'require' => Anchor['zookeeper::os::debian::java']}
    )
  } else {
    # allow installing multiple packages, like zookeeper, zookeeper-bin etc.
    ensure_resource('package', $packages, {'ensure' => $ensure})
  }

  if ($start_with == 'init.d') {
    package { [$service_package]: #init.d scripts for zookeeper
      ensure  => $ensure,
      require => Package['zookeeper']
    }
  }

  # since ZooKeeper 3.4 there's no need for purging snapshots with cron
  case $::operatingsystem {
    'Debian': {
      case $::lsbdistcodename {
        'wheezy', 'squeeze': { # 3.3.5
          $manual_clean = true
        }
        default: { # future releases
          $manual_clean = false
        }
      }
    }
    'Ubuntu': {
      case $::lsbdistcodename {
        'precise': { # 3.3.5
          $manual_clean = true
        }
        default: {
          $manual_clean = false
        }
      }
    }
    default: {
      fail ("Family: '${::osfamily}' OS: '${::operatingsystem}' is not supported yet")
    }
  }


  # if !$cleanup_count, then ensure this cron is absent.
  if ($manual_clean and $snap_retain_count > 0 and $ensure != 'absent') {

    if ($ensure_cron){
      ensure_resource('package', 'cron', {
        ensure => 'installed',
      })

      cron { 'zookeeper-cleanup':
          ensure  => present,
          command => "${cleanup_sh} ${datastore} ${snap_retain_count}",
          hour    => 2,
          minute  => 42,
          user    => $user,
          require => Package['zookeeper'],
      }
    }else {
      file { '/etc/cron.daily/zkcleanup':
        ensure  => present,
        content =>  "${cleanup_sh} ${datastore} ${snap_retain_count}",
        require => Package['zookeeper'],
      }
    }
  }

  # package removal
  if($manual_clean and $ensure == 'absent'){
    if ($ensure_cron){
      cron { 'zookeeper-cleanup':
        ensure  => $ensure,
      }
    }else{
      file { '/etc/cron.daily/zkcleanup':
        ensure  => $ensure,
      }
    }
  }
}