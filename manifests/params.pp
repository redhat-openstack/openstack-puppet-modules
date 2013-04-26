class zookeeper::params {
  
  $myid        = hiera('myid', '1')
  $datastore   = hiera('datastore', '/var/lib/zookeeper')
  $client_port = hiera('client_port', 2181)
  $snap_count  = hiera('snap_count', 10000)
  $log_dir     = hiera('log_dir', '/var/log/zookeeper')
  $cfg_dir     = hiera('cfg_dir', '/etc/zookeeper/conf')
  $user        = hiera('user', 'zookeeper')
  $group       = hiera('group', 'zookeeper')
  $java_bin    = hiera('java_bin', '/usr/bin/java')
  $java_opts   = hiera('java_opts', '')
  $pid_dir     = hiera('pid_dir', '/var/run/zookeeper')
  $pid_file    = hiera('pid_file', '$PIDDIR/zookeeper.pid')
  $zoo_main    = hiera('zoo_main', 'org.apache.zookeeper.server.quorum.QuorumPeerMain')
  $lo4j_prop   = hiera('log4j_prop', 'INFO,ROLLINGFILE')

  $servers     = hiera_array('zookeeper_servers', [''])

  # log4j properties
  $rollingfile_threshold = hiera('rollingfile_threshold', 'ERROR')
  $tracfile_threshold    = hiera('tracefile_threshold', 'TRACE')


  
}
