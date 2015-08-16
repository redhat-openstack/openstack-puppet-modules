# cassandra::firewall_ports::rule
define cassandra::firewall_ports::rule(
    $ports,
  ) {
  $array_var1 = split($title, '_')
  $rule_number = $array_var1[1]
  $proto_name = $array_var1[2]
  $source = $array_var1[3]

  firewall { "${rule_number} (${proto_name}) - ${source}":
    action => 'accept',
    port   => $ports,
    proto  => 'tcp',
    source => $source
  }
}
