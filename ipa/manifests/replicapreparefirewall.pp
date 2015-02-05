define ipa::replicapreparefirewall (
  $host   = $name,
  $source = {}
) {

  firewall { "103 allow SSH from IPA master ${host}":
    ensure => 'present',
    action => 'accept',
    proto  => 'tcp',
    source => $source,
    dport  => ['22']
  }
}
