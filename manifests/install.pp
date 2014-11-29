# Class: zookeeper::install
#
# This module manages Zookeeper installation
#
# Parameters: None
#
# Actions: None
#
# Requires:
#
# Sample Usage: include zookeeper::install
#
class zookeeper::install(
  $ensure            = present,
  $snap_retain_count = 3,
  $cleanup_sh        = '/usr/lib/zookeeper/bin/zkCleanup.sh',
  $datastore         = '/var/lib/zookeeper',
  $user              = 'zookeeper',
) {
  anchor { 'zookeeper::install::begin': }
  anchor { 'zookeeper::install:end': }

  case $::osfamily {
    Debian: {
      class { 'zookeeper::os::debian':
        ensure            => $ensure,
        snap_retain_count => $snap_retain_count,
        cleanup_sh        => $cleanup_sh,
        datastore         => $datastore,
        user              => $user,
        before            => Anchor['zookeeper::install::end'],
        require           => Anchor['zookeeper::install::begin'],
      }
    }
    RedHat: {
      class { 'zookeeper::os::redhat':
        ensure            => $ensure,
        snap_retain_count => $snap_retain_count,
        cleanup_sh        => $cleanup_sh,
        datastore         => $datastore,
        user              => $user,
        require           => Anchor['zookeeper::install::begin'],
        before            => Anchor['zookeeper::install::end'],
      }
    }
    default: {
      fail("Module '${module_name}' is not supported on OS: '${::operatingsystem}', family: '${::osfamily}'")
    }
  }
}

