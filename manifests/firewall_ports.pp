# Allow a user to configure the cassandra specific firewall ports.
#
# See the module readme for more details.
class cassandra::firewall_ports (
  $client_additional_ports     = [],
  $client_subnets              = ['0.0.0.0/0'],
  $inter_node_additional_ports = [],
  $inter_node_subnets          = ['0.0.0.0/0'],
  $public_additional_ports     = [],
  $public_subnets              = ['0.0.0.0/0'],
  $ssh_port                    = 22,
  $opscenter_additional_ports  = [],
  $opscenter_subnets           = ['0.0.0.0/0']
  ) {
  # Public connections on any node.
  $public_subnets_ssh_array = prefix($public_subnets, '200_SSH_')

  cassandra::firewall_ports::rule { $public_subnets_ssh_array:
    ports => [$ssh_port]
  }

  # If this is a Cassandra node.
  if defined ( Class['::cassandra'] ) {
    # Inter-node connections for Cassandra
    $inter_node_subnets_array = prefix($inter_node_subnets,
      '210_CassandraInterNode_')
    $inter_node_ports = [$cassandra::storage_port,
      $cassandra::ssl_storage_port, 7199]

    cassandra::firewall_ports::rule { $inter_node_subnets_array:
      ports => concat([$inter_node_ports], $inter_node_additional_ports)
    }

    # Client connections for Cassandra
    $client_subnets_array = prefix($client_subnets, '220_CassandraClient_')
    $client_node_ports = [$cassandra::native_transport_port,
      $cassandra::rpc_port]

    cassandra::firewall_ports::rule {$client_subnets_array:
      ports => concat([$client_node_ports], $client_additional_ports)
    }
  }

  # Connections for DataStax Agent
  if defined ( Class['::cassandra::datastax_agent'] ) {
    $opscenter_subnets_opc_agent = prefix($opscenter_subnets,
      '230_OpsCenterAgent_')

    cassandra::firewall_ports::rule { $opscenter_subnets_opc_agent:
      ports => concat([61621], $opscenter_additional_ports)
    }
  }

  # Connections for OpsCenter
  if defined ( Class['::cassandra::opscenter'] ) {
    $public_subnets_opscenter_array = prefix($public_subnets,
      '240_OpsCenterWeb_')
    $opscenter_port = [ $cassandra::opscenter::webserver_port,
      $cassandra::opscenter::webserver_ssl_port ]

    cassandra::firewall_ports::rule { $public_subnets_opscenter_array:
      ports => concat([$cassandra::opscenter::webserver_port],
                $public_additional_ports)
    }

    $opscenter_subnets_opc_server = prefix($opscenter_subnets,
      '250_OpsCenterServer_')

    cassandra::firewall_ports::rule { $opscenter_subnets_opc_server:
      ports => concat([61620], $opscenter_additional_ports)
    }
  }
}
