define ipa::hostadd (
  $host = $name,
  $otp = {},
  $desc = {},
  $locality = {},
  $location = {}
) {

  $timestamp = strftime("%a %b %d %Y %r")
  $descinfo = rstrip(join(['Added by HUIT IPA Puppet module on',$timestamp,$desc], " ")) 

  exec {
    "hostadd-${host}":
      command   => "/sbin/runuser -l admin -c \'/usr/bin/ipa host-add ${host} --locality=\"${locality}\" --location=\"${location}\" --desc=\"${descinfo}\" --platform=\"${::manufacturer}\" --os=\"${::lsbdistdescription}\" --password=${otp}\'",
      unless    => "/sbin/runuser -l admin -c \'/usr/bin/ipa host-show ${host} >/dev/null 2>&1\'",
      tries     => '60',
      try_sleep => '60',
  }
}
