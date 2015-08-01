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
  cassandra::firewall_ports::rule { $public_subnets:
    port   => $ssh_port,
  }

  if $::cassandra::opscenter::webserver_port != undef {
    cassandra::firewall_ports::rule { $public_subnets:
      port   => $::cassandra::opscenter::webserver_port,
    }
  }
}
