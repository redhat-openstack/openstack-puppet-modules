# == Class: cassandra
#
# Full description of class cassandra here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { 'cassandra':
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2015 Your name here, unless otherwise noted.
#
class cassandra (
  $cluster_name                  = undef,
  $cassandra_package_name        = 'dsc21',
  $cassandra_package_ensure      = 'present',
  $cassandra_opt_package_name    = undef,
  $cassandra_opt_package_ensure  = 'present',
  $java_package_name             = undef,
  $java_package_ensure           = 'present',
  $manage_dsc_repo               = false,
  ) {

  if $manage_dsc_repo == true {
    yumrepo { 'datastax':
      ensure   => present,
      descr    => 'DataStax Repo for Apache Cassandra',
      baseurl  => 'http://rpm.datastax.com/community',
      enabled  => 1,
      gpgcheck => 0,
      before   => Package[ $cassandra_package_name ],
    }
  }

  if $java_package_name != undef {
    package { $java_package_name:
      ensure => $java_package_ensure,
      before => Package[ $cassandra_package_name ],
    }
  }

  package { $cassandra_package_name:
    ensure => $cassandra_package_ensure,
  }

  if $cassandra_opt_package_name != 'undef' {
    package { $cassandra_opt_package_name:
      ensure  => $cassandra_opt_package_ensure,
      require => Package[$cassandra_package_name],
    }
  }
}
