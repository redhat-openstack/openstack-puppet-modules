define ipa::syncdirsvc (
  $host       = $name,
  $ipaservers = [],
  $mkhomedir  = {}
) {

  Exec["syncdirsvc-${host}"] ~> Ipa::Flushcache["client-${host}"]

  $servers = chop(inline_template('<% @ipaservers.each do |@ipaserver| -%><%= @ipaserver %>,<% done -%>'))

  $mkhomediropt = $mkhomedir ? {
    true    => '--enablemkhomedir',
    default => ''
  }

  exec { "client-install-${host}":
    command     => "/usr/sbin/authconfig --ldapserver=${servers} --krb5kdc=${servers} --krb5adminserver=${servers} ${mkhomediropt} --update",
    refreshonly => true,
    logoutput   => "on_failure"
  }<- notify { "Syncing IPA directory services, please wait.": }

  ipa::flushcache { "syncdirsvc-${host}":
  }
}
