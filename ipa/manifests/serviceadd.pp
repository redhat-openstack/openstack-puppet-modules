define ipa::serviceadd (
  $principal = $name,
  $host      = undef,
  $service   = undef,
  $realm     = undef,
) {

  if $host and $service {
    $parsed_principal = $realm ? {
      true    => "${service}/${host}",
      default => "${service}/${host}@${realm}",
    }
  } else {
    $parsed_principal = $principal
  }

  Ipa::Hostadd<||> -> Exec["serviceadd-${parsed_principal}"]

  exec { "serviceadd-${parsed_principal}":
    command   => "/sbin/runuser -l admin -c \'/usr/bin/ipa service-add ${parsed_principal} --force \'",
    unless    => "/sbin/runuser -l admin -c \'/usr/bin/ipa service-show ${parsed_principal} >/dev/null 2>&1\'",
    tries     => '60',
    try_sleep => '60',
  }
}
