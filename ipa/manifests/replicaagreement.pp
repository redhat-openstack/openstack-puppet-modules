define ipa::replicaagreement (
  $from,
  $to
) {
  exec { "connect-${from}-${to}":
    command   => "/sbin/runuser -l admin -c \'/usr/sbin/ipa-replica-manage connect ${from} ${to}\'",
    unless    => "/sbin/runuser -l admin -c \'/usr/sbin/ipa-replica-manage list ${from} | /bin/grep ${to} >/dev/null 2>&1\'",
    logoutput => 'on_failure',
  }
}
