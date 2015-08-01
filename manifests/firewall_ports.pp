# Allow a user to configure the cassandra specific firewall ports.
#
# See the module readme for more details.
class cassandra::firewall_ports (
  $client_subnets     = ['0.0.0.0/0'],
  $inter_node_subnets = ['0.0.0.0/0'],
  $public_subnets     = ['0.0.0.0/0'],
  $ssh_action         = 'accept',
  $ssh_port           = 22,
  $opscenter_subnets  = ['0.0.0.0/0']
  ) {
  cassandra::firewall_ports::rule { $public_subnets:
    action => $ssh_action,
    port   => $ssh_port,
  }
}
