class zookeeper::params {
  
  $myid        = hiera('zookeeper::id', '1')
  $datastore   = hiera('zookeeper::datastore', '/var/lib/zookeeper')
  $client_port = hiera('zookeeper::client_port', 2181)
  $snap_count  = hiera('zookeeper::snap_count', 10000)
  $log_dir     = hiera('zookeeper::log_dir', '/var/log/zookeeper')
  $cfg_dir     = hiera('zookeeper::cfg_dir', '/etc/zookeeper/conf')
  $user        = hiera('zookeeper::user', 'zookeeper')
  $group       = hiera('zookeeper::group', 'zookeeper')
  $java_bin    = hiera('zookeeper::java_bin', '/usr/bin/java')
  $java_opts   = hiera('zookeeper::java_opts', '')
  $pid_dir     = hiera('zookeeper::pid_dir', '/var/run/zookeeper')
  $pid_file    = hiera('zookeeper:pid_file', '$PIDDIR/zookeeper.pid')
  $zoo_main    = hiera('zookeeper::zoo_main', 'org.apache.zookeeper.server.quorum.QuorumPeerMain')
  $lo4j_prop   = hiera('zookeeper::log4j_prop', 'INFO,ROLLINGFILE')


  $servers     = hiera_array('zookeeper::servers', [''])

  $snapRetainCount = hiera('zookeeper::snapRetainCount', 3)
  # interval in hours, purging enabled when >= 1
  $purgeInterval   = hiera('zookeeper::purgeInterval', 0)

  # log4j properties
  $rollingfile_threshold = hiera('zookeeper::rollingfile_threshold', 'ERROR')
  $tracefile_threshold    = hiera('zookeeper::tracefile_threshold', 'TRACE')
  
}
