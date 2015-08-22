#############################################################################
# This manifest file is only for Vagrant testing.  It is not a functional
# part of the cassandra module.
#############################################################################

node /cassandra/ {
    class { '::cassandra::datastax_repo': } ->
    class { '::cassandra::java': } ->
    class { 'cassandra':
      cassandra_9822  => true
    } ->
    class { '::cassandra::optutils': } ->
    class { '::cassandra::datastax_agent': } ->
    class { '::cassandra::opscenter::pycrypto':
      manage_epel => true,
    } ->
    class { '::cassandra::opscenter': } ->
    class { '::cassandra::firewall_ports': }
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
