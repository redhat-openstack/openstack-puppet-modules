define ipa::flushcache (
  $host = $name
) {

  $flushcmd = $::osfamily ? {
    'RedHat' => "/usr/sbin/sss_cache -UGN >/dev/null 2>&1",
    'Debian' => "/usr/sbin/nscd -i passwd -i group -i netgroup >/dev/null 2>&1 ; /usr/sbin/sss_cache -UGN >/dev/null 2>&1",
  }

  exec {
    "flushcache-${host}":
      command     => $flushcmd,
      notify      => Service["sssd"],
      refreshonly => true,
  }
}
