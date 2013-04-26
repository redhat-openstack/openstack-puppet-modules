class zookeeper::params {
  
  $myid        = params_lookup('myid', '1')
  $datastore   = params_lookup('datastore', '/var/lib/zookeeper')
  $client_port = params_lookup('client_port', 2181)
  $snap_count  = params_lookup('snap_count', 10000)
  $log_dir     = params_lookup('log_dir', '/var/log/zookeeper')
  $cfg_dir     = params_lookup('cfg_dir', '/etc/zookeeper/conf')
  $user        = params_lookup('user', 'zookeeper')
  $group       = params_lookup('group', 'zookeeper')
  $java_bin    = params_lookup('java_bin', '/usr/bin/java')
  $java_opts   = params_lookup('java_opts', '')
  $pid_dir     = params_lookup('pid_dir', '/var/run/zookeeper')
  $pid_file    = params_lookup('pid_file', '$PIDDIR/zookeeper.pid')
  $zoo_main    = params_lookup('zoo_main', 'org.apache.zookeeper.server.quorum.QuorumPeerMain')
  $lo4j_prop   = params_lookup('log4j_prop', 'INFO,ROLLINGFILE')

  $servers     = params_lookup('zookeeper_servers', [''], local, array)

  # log4j properties
  $rollingfile_threshold = params_lookup('rollingfile_threshold', 'ERROR')
  $tracfile_threshold    = params_lookup('tracefile_threshold', 'TRACE')


  
}
