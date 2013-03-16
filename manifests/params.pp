class zookeeper::params {
  case $::operatingsystem {
    debian, ubuntu: {
      $tmp_dir         = "/tmp"
      $datastore       = "/usr/lib/zookeeper/data"
      $datastore_log   = "/var/log/zookeeper/datastore"
      $log_dir         = "/var/log/zookeeper"
      $init_d_path     = "/etc/init.d/zookeeper"
      $init_d_template = "zookeeper/service/zookeeper.erb"
      $user            = "root"
      $version         = "3.4.5"
      $zookeeper_path  = "/usr/lib"
    }
    default: {
      case $::osfamily {
        default: {
          fail("Unsupported platform: ${::osfamily}/${::operatingsystem}")
        }
      }
    }
  }
}
