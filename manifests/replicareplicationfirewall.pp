define ipa::replicareplicationfirewall (
  $host   = $name,
  $source = {}
) {

  firewall { "104 allow IPA replication services from replica ${host}":
    ensure => 'present',
    action => 'accept',
    proto  => 'tcp',
    source => $source,
    dport  => ['9443','9444','9445','7389']
  }
}
