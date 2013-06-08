define ipa::flushcache (
  $host = $name
) {

  $flushcmd = $::osfamily ? {
    'RedHat' => "/bin/bash -c \"if [ -x /usr/sbin/sss_cache ]; then /usr/sbin/sss_cache -UGN >/dev/null 2>&1 ; else /usr/bin/find /var/lib/sss/db -type f -exec rm -f '{}' \; ; fi\"",
    'Debian' => "/usr/sbin/nscd -i passwd -i group -i netgroup >/dev/null 2>&1 ; /usr/sbin/sss_cache -UGN >/dev/null 2>&1"
  }

  exec { "flushcache-${host}":
    command     => $flushcmd,
    notify      => Service["sssd"],
    refreshonly => true
  }
}
