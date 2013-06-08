define ipa::hostdelete (
  $host = $name
) {

  exec { "hostdelete-${host}":
    command     => "/sbin/runuser -l admin -c \'/usr/bin/ipa host-del ${host}\'",
    refreshonly => true,
    onlyif      => "/sbin/runuser -l admin -c \'/usr/bin/ipa host-show ${host} >/dev/null 2>&1\'"
  }
}
