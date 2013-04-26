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
class zookeeper {
  include zookeeper::install
  include zookeeper::config
  
  service { "zookeeper":
    ensure  => "running",
    enable  => "true",
  }

}
