# cassandra::firewall_ports::rule
define cassandra::firewall_ports::rule(
    $action,
    $port,
    $source = $title,
  ) {
  # Need the following code block to excluded from Coveralls.io analysis
  # because we're not responsible for PuppetLabs code.
  # :nocov:
  Firewall { "${port} - ${source}":
    action => $action,
    port   => $port,
    proto  => 'tcp',
    source => $source
  }
  # :nocov:
}
