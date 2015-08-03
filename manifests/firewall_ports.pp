# Allow a user to configure the cassandra specific firewall ports.
#
# See the module readme for more details.
class cassandra::firewall_ports (
  $client_subnets     = ['0.0.0.0/0'],
  $inter_node_subnets = ['0.0.0.0/0'],
  $public_subnets     = ['0.0.0.0/0'],
  $ssh_port           = 22,
  $opscenter_subnets  = ['0.0.0.0/0']
  ) {
  $inter_node_subnets_array = prefix($inter_node_subnets, 'Cassandra_')
  $inter_node_ports = [$::cassandra::storage_port,
    $::cassandra::ssl_storage_port, 7199]
  cassandra::firewall_ports::rule { $inter_node_subnets_array:
    port => $inter_node_ports
  }

  $public_subnets_ssh_array = prefix($public_subnets, 'SSH_')
  cassandra::firewall_ports::rule { $public_subnets_ssh_array:
    port => $ssh_port
  }

  if defined ( Class['::cassandra::datastax_agent'] ) {
    $opscenter_subnets_opc_agent = prefix($opscenter_subnets,
      'OpsCenterAgent_')
    cassandra::firewall_ports::rule { $opscenter_subnets_opc_agent:
      port => 61621
    }
  }

  if defined ( Class['::cassandra::opscenter'] ) {
    $public_subnets_opscenter_array = prefix($public_subnets,
      'OpsCenterWeb_')
    $opscenter_port = [ $::cassandra::opscenter::webserver_port,
      $::cassandra::opscenter::webserver_ssl_port ]

    cassandra::firewall_ports::rule { $public_subnets_opscenter_array:
      port => $::cassandra::opscenter::webserver_port
    }

    $opscenter_subnets_opc_server = prefix($opscenter_subnets,
      'OpsCenterServer_')
    cassandra::firewall_ports::rule { $opscenter_subnets_opc_server:
      port => 61620
    }
  }
}
