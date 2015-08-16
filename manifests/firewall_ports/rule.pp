# cassandra::firewall_ports::rule
define cassandra::firewall_ports::rule(
    $ports,
  ) {
  $array_var1 = split($title, '_')
  $proto_name = $array_var1[0]
  $source = $array_var1[1]
  firewall { "${port} (${proto_name}) - ${source}":
    action => 'accept',
    port   => $port,
    proto  => 'tcp',
    source => $source
  }
}
