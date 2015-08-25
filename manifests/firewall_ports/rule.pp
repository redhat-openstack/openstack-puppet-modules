# cassandra::firewall_ports::rule
define cassandra::firewall_ports::rule(
    $ports
  ) {
  $array_var1 = split($title, '_')
  $rule_number = $array_var1[0]
  $rule_description = $array_var1[1]
  $source = $array_var1[2]

  if size($ports) > 0 {
    firewall { "${rule_number} - Cassandra (${rule_description}) - ${source}":
      action => 'accept',
      dport  => $ports,
      proto  => 'tcp',
      source => $source
    }
  }
}
