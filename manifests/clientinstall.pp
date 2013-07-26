define ipa::clientinstall (
  $host       = $name,
  $masterfqdn = {},
  $domain     = {},
  $realm      = {},
  $adminpw    = {},
  $otp        = {},
  $mkhomedir  = {},
  $ntp        = {}
) {

  Exec["client-install-${host}"] ~> Ipa::Flushcache["client-${host}"]

  $mkhomediropt = $mkhomedir ? {
    true    => '--mkhomedir',
    default => ''
  }

  $ntpopt = $ntp ? {
    true    => '',
    default => '--no-ntp'
  }

  $dc = prefix([regsubst($domain,'(\.)',',dc=','G')],'dc=')

  exec { "client-install-${host}":
    command   => "/bin/echo | /usr/sbin/ipa-client-install --server=${masterfqdn} --hostname=${host} --domain=${domain} --realm=${realm} --password=${otp} ${mkhomediropt} ${ntpopt} --unattended",
    unless    => "/bin/bash -c \"LDAPTLS_REQCERT=never /usr/bin/ldapsearch -LLL -x -H ldaps://${masterfqdn} -D uid=admin,cn=users,cn=accounts,${dc} -b ${dc} -w ${adminpw} fqdn=${host} | /bin/grep ^krbPrincipalName\"",
    timeout   => '0',
    tries     => '60',
    try_sleep => '90',
    returns   => ['0','1'],
    logoutput => "on_failure"
  }<- notify { "Running IPA client install, please wait.": }

  ipa::flushcache { "client-${host}":
  }
}
