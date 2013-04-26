define ipa::puppetrunin1min {
  exec {
    "${name}":
      command     => "/bin/echo '/usr/bin/puppet agent --test' | /usr/bin/at now + 1 min >/dev/null 2>&1",
      logoutput   => true,
      refreshonly => true,
  }
}
