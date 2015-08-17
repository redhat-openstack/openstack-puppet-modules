# Allow a user to configure the cassandra specific firewall ports.
#
# See the module readme for more details.
class cassandra::firewall_ports (
  $client_ports                = [9042, 9160],
  $client_subnets              = ['0.0.0.0/0'],
  $inter_node_ports            = [7000, 7001, 7199],
  $inter_node_subnets          = ['0.0.0.0/0'],
  $public_ports                = [8888],
  $public_subnets              = ['0.0.0.0/0'],
  $ssh_port                    = 22,
  $opscenter_ports             = [61620, 61621],
  $opscenter_subnets           = ['0.0.0.0/0']
  ) {
  # Public connections on any node.
  $public_subnets_array = prefix($public_subnets, '200_Public_')

  cassandra::firewall_ports::rule { $public_subnets_array:
    ports => concat($public_ports, [$ssh_port])
  }

  # If this is a Cassandra node.
  if defined ( Class['::cassandra'] ) {
    # Inter-node connections for Cassandra
    $inter_node_subnets_array = prefix($inter_node_subnets,
      '210_InterNode_')

    cassandra::firewall_ports::rule { $inter_node_subnets_array:
      ports => $inter_node_ports
    }

    # Client connections for Cassandra
    $client_subnets_array = prefix($client_subnets, '220_Client_')

    cassandra::firewall_ports::rule {$client_subnets_array:
      ports => $client_ports
    }
  }

  # Connections for DataStax Agent
  if defined ( Class['::cassandra::datastax_agent'] ) or
    defined ( Class['::cassandra::opscenter'] ) {
    $opscenter_subnets_opc_agent = prefix($opscenter_subnets,
      '230_OpsCenter_')

    cassandra::firewall_ports::rule { $opscenter_subnets_opc_agent:
      ports => $opscenter_ports
    }
  }
}
