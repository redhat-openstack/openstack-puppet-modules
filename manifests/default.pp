#############################################################################
# This manifest file is only for Vagrant testing.  It is not a functional
# part of the cassandra module.
#############################################################################

node default {
  class { 'cassandra':
    manage_dsc_repo => true,
    cassandra_9822  => true
  }

  include '::cassandra::datastax_agent'
  include '::cassandra::java'
  include '::cassandra::opscenter'

  class { '::cassandra::opscenter::pycrypto':
    manage_epel => true
  }

  include '::cassandra::optutils'
}
