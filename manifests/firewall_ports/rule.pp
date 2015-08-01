# cassandra::firewall_ports::rule
define cassandra::firewall_ports::rule(
    $port,
    $source = $title,
  ) {
  Firewall { "${port} - ${source}":
    action => 'accept',
    port   => $port,
    proto  => 'tcp',
    source => $source
  }
}
