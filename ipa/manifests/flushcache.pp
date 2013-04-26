define ipa::flushcache (
  $host = $name
) {
  exec {
    "flushcache-${host}":
      command => "/usr/sbin/sss_cache -U >/dev/null 2>&1",
      refreshonly => true,
  }
}
