#
# ZooKeeper installation on Debian
class zookeeper::os::redhat(
  $ensure            = present,
  $snap_retain_count = 3,
  $cleanup_sh        = '/usr/lib/zookeeper/bin/zkCleanup.sh',
  $datastore         = '/var/lib/zookeeper',
  $user              = 'zookeeper',
  $ensure_cron       = true,
  $packages          = ['zookeeper'],
  $manual_clean      = false,
  $install_java      = false,
  $java_package      = undef
) {

  validate_bool($install_java)

  # if $install_java, try to make sure a JDK package is installed
  if ($install_java){
    if !$java_package {
      fail { "Java installation is required, but no java package was provided.": }
    }

    validate_string($java_package)

    package{ $java_package:
      ensure        => present,
      allow_virtual => true,
      before        => Anchor['zookeeper::install::package::begin'],
    }
  }

  anchor { 'zookeeper::install::package::begin': }->
  package { $packages:
    ensure => present
  }->
  anchor { 'zookeeper::install::package::end': }

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
