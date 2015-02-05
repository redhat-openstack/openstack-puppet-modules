define ipa::flushcache (
  $host = $name
) {

  $flushcmd = $::osfamily ? {
    'RedHat' => shellquote('if [ -x /usr/sbin/sss_cache ]; then /usr/sbin/sss_cache -UGNA >/dev/null 2>&1 ; else /usr/bin/find /var/lib/sss/db -type f -exec rm -f "{}" \; ; fi'),
    'Debian' => shellquote('if [ -x /usr/sbin/nscd ]; then /usr/sbin/nscd -i passwd -i group -i netgroup -i automount >/dev/null 2>&1 ; elif [ -x /usr/sbin/sss_cache ]; then /usr/sbin/sss_cache -UGNA >/dev/null 2>&1 ; else /usr/bin/find /var/lib/sss/db -type f -exec rm -f "{}" \; ; fi')
  }

  exec { "flushcache-${host}":
    command     => "/bin/bash -c ${flushcmd}",
    returns     => ['0','1','2'],
    notify      => Service['sssd'],
    refreshonly => true
  }
}
