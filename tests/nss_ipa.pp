certmonger::request_ipa_cert {'test':
  seclib => "nss",
  nickname => "Server-Cert",
  principal => "nss_test/${fqdn}",
  basedir => '/tmp/nssdb',
}
