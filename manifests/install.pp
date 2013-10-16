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
  $snap_retain_count = 3,
  $cleanup_sh        = '/usr/lib/zookeeper/bin/zkCleanup.sh',
  $datastore         = '/var/lib/zookeeper',
) {
# a debian (or other binary package) must be available, see https://github.com/deric/zookeeper-deb-packaging
# for Debian packaging
  package { ['zookeeper']:
    ensure => present
  }
  ->
  package { ['zookeeperd']: #init.d scripts for zookeeper
    ensure => present
  }
  ->
  cron::daily{
    'zookeeper_log_daily':
      minute  => '40',
      hour    => '2',
      user    => 'root',
      command => "${cleanup_sh} ${datastore} ${snap_retain_count}";
  }

}

