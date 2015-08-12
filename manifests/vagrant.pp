#############################################################################
# This manifest file is only for Vagrant testing.  It is not a functional
# part of the cassandra module.
#############################################################################

node /^node\d+$/ {
  class { 'cassandra::datastax_repo':
    before => Class['cassandra']
  }

  class { 'cassandra::java':
    before => Class['cassandra']
  }

  class { 'cassandra':
    cluster_name    => 'MyCassandraCluster',
    endpoint_snitch => 'GossipingPropertyFileSnitch',
    listen_address  => "${::ipaddress}",
    num_tokens      => 256,
    seeds           => '110.82.155.0,110.82.156.3'
  }

  include cassandra::optutils
}


node /opscenter/ {
  require '::cassandra::datastax_repo'
  include '::cassandra::opscenter'

  cassandra::opscenter::cluster_name { 'remote_cluster':
    cassandra_seed_hosts       => 'localhost',
    storage_cassandra_username => 'opsusr',
    storage_cassandra_password => 'opscenter',
    storage_cassandra_api_port => 9160,
    storage_cassandra_cql_port => 9042,
    storage_cassandra_keyspace => 'OpsCenter_Cluster1'
  }

  class { '::cassandra::opscenter::pycrypto':
    manage_epel => true
  }
}
