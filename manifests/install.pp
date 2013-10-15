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
class zookeeper::install {
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
      command => '/usr/lib/zookeeper/bin/zkCleanup.sh /var/zookeeper_datastore 3';
  }

}

