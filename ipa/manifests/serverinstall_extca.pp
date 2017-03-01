# Definition: ipa::serverinstall_extca
#
# Completes installation an IPA server with an external CA
define ipa::serverinstall_extca (
  $host             = $name,
  $adminpw          = {},
  $dspw             = {},
  $extcertpath      = {},
  $extcacertpath    = {},
  $dirsrv_pkcs12opt = {},
  $http_pkcs12opt   = {},
  $dirsrv_pinopt    = {},
  $http_pinopt      = {},
  $subjectopt       = {},
  $selfsignopt      = {}
) {

  exec { "extca_serverinstall-${host}":
    command     => shellquote('/usr/sbin/ipa-server-install',"--external_cert_file=${extcertpath}","--external_ca_file=${extcacertpath}",$dirsrv_pkcs12opt,$http_pkcs12opt,$dirsrv_pinopt,$http_pinopt,$subjectopt,$selfsignopt,'--unattended'),
    timeout     => '0',
    refreshonly => true,
    notify      => Ipa::Flushcache["server-${host}"],
    require     => File[$extcertpath,$extcacertpath],
    logoutput   => 'on_failure'
  }

  ipa::flushcache { "server-${host}":
  }
}
