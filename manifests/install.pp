# Class: zookeeper::install
#
# This module manages Mesos installation
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
  
  # linux containers
  zookeeper::requires { "$name-requires-zookeeper": package => 'zookeeper' }

  # a debian (or other binary package) must be available, see https://github.com/deric/zookeeper-deb-packaging 
  # for Debian packaging
  package { ['zookeeper']:
    ensure => present
  }

  define zookeeper::requires ( $ensure='installed', $package ) {
   if defined( Package[$package] ) {
    debug("$package already installed")
   } else {
    package { $package: ensure => $ensure }
   }
 } 
}

