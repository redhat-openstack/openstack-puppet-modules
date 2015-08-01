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
  $public_subnets_ssh_array = prefix($public_subnets, 'SSH_')
  cassandra::firewall_ports::rule { $public_subnets_ssh_array:
    port => $ssh_port
  }

  if defined ( Class['::cassandra::opscenter'] ) {
    $public_subnets_opscenter_array = prefix($public_subnets, 'OpsCenter_')

    if $::cassandra::opscenter::webserver_port != undef and
      $::cassandra::opscenter::webserver_ssl_port == undef
    {
      $opscenter_port = $::cassandra::opscenter::webserver_port
    } elsif $::cassandra::opscenter::webserver_port == undef and
      $::cassandra::opscenter::webserver_ssl_port != undef
    {
      $opscenter_port = $::cassandra::opscenter::webserver_ssl_port
    } else {
      $opscenter_port = [$::cassandra::opscenter::webserver_port,
        $::cassandra::opscenter::webserver_ssl_port ]
    }

    cassandra::firewall_ports::rule { $public_subnets_opscenter_array:
      port => $::cassandra::opscenter::webserver_port
    }
  }
}
