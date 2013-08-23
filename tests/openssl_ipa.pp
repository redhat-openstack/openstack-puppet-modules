certmonger::request_ipa_cert {'test':
  seclib => "openssl",
  principal => "openssl_test/${fqdn}",
  key => "/tmp/test.key",
  cert => "/tmp/test.crt",
  owner_id => 'rcrit',
  group_id => 'rcrit'
}
