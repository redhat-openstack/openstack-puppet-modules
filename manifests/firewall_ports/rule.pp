# cassandra::firewall_ports::rule
define cassandra::firewall_ports::rule(
    $action,
    $port,
    $source = $title,
  ) {
  Firewall { "${port} - ${source}":
    action => $action,
    port   => $port,
    proto  => 'tcp',
    source => $source
  }
}
