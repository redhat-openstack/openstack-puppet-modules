define ipa::clientinstall (
  $host = $name,
  $masterfqdn = {},
  $domain = {},
  $realm = {},
  $dspw = {},
  $otp = {},
  $mkhomedir = {},
  $ntp = {}
) {

  Exec["client-install-${host}"] ~> Ipa::Flushcache["client-${host}"]

  $dc = prefix([regsubst($domain,'(\.)',',dc=','G')],'dc=')

  exec {
    "client-install-${host}":
      command   => "/bin/echo | /usr/sbin/ipa-client-install --server=${masterfqdn} --hostname=${host} --domain=${domain} --realm=${realm} --password=${otp} ${mkhomedir} ${ntp} --unattended",
      unless    => "/bin/bash -c \"LDAPTLS_REQCERT=never /usr/bin/ldapsearch -LLL -x -H ldaps://${masterfqdn} -D uid=admin,cn=users,cn=accounts,${dc} -b ${dc} -w ${dspw} fqdn=${host} | /bin/grep ^krbPrincipalName\"",
      timeout   => '0',
      tries     => '60',
      try_sleep => '60',
      logoutput => "on_failure",
  }<- notify { "Running IPA client install, please wait.": }

  ipa::flushcache {
    "client-${host}":
  }
}
