# Class: zookeeper
#
# This module manages zookeeper
#
# Parameters:
#   user
#   group
#   log_dir
#
# Requires:
#   N/A
# Sample Usage:
#
#   class { 'zookeeper': }
#
class zookeeper(
  $id          = '1',
  $datastore   = '/var/lib/zookeeper',
  $client_port = 2181,
  $snap_count  = 10000,
  $log_dir     = '/var/log/zookeeper',
  $cfg_dir     = '/etc/zookeeper/conf',
  $user        = 'zookeeper',
  $group       = 'zookeeper',
  $java_bin    = '/usr/bin/java',
  $java_opts   = '',
  $pid_dir     = '/var/run/zookeeper',
  $pid_file    = '$PIDDIR/zookeeper.pid',
  $zoo_main    = 'org.apache.zookeeper.server.quorum.QuorumPeerMain',
  $lo4j_prop   = 'INFO,ROLLINGFILE',
  $servers     = [''],
  # since zookeeper 3.4, for earlier version cron task might be used
  $snap_retain_count = 3,
  # interval in hours, purging enabled when >= 1
  $purge_interval   = 0,
  # log4j properties
  $rollingfile_threshold = 'ERROR',
  $tracefile_threshold    = 'TRACE',
) {

  anchor { 'zookeeper::start': }->
  class { 'zookeeper::install':
    snap_retain_count  => $snap_retain_count,
    datastore          => $datastore,
  }->
  class { 'zookeeper::config':
    id        => $id,
    user      => $user,
    group     => $group,
    log_dir   => $log_dir,
    cfg_dir   => $cfg_dir,
    datastore => $datastore
  }->
  anchor { 'zookeeper::end': }

  service { 'zookeeper':
    ensure  => 'running',
    enable  => true,
    require => Anchor['zookeeper::end']
  }

}
