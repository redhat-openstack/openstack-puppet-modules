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
  
  anchor { 'zookeeper::start': }->
  class { 'zookeeper::install': }->
  class { 'zookeeper::config': }->
  anchor { 'zookeeper::end': }
    
  service { "zookeeper":
    ensure  => "running",
    enable  => "true",
  }

}
