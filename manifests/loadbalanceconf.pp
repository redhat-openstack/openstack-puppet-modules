define ipa::loadbalanceconf (
  $host       = $name,
  $ipaservers = [],
  $mkhomedir  = {}
) {

  Exec["loadbalanceconf-authconfig-${host}"] ~> Ipa::Flushcache["loadbalanceconf-flushcache-${host}"]

  $servers = chop(inline_template('<% ipaservers.each do |ipaserver| -%><%= ipaserver %>,<% done -%>'))

  $mkhomediropt = $mkhomedir ? {
    true    => '--enablemkhomedir',
    default => ''
  }

  exec { "loadbalanceconf-authconfig-${host}":
    command     => "/usr/sbin/authconfig --ldapserver=${servers} --krb5kdc=${servers} --krb5adminserver=${servers} ${mkhomediropt} --update",
    refreshonly => true,
    logoutput   => "on_failure"
  }<- notify { "Addling load balanced IPA directory services, please wait.": }

  ipa::flushcache { "loadbalanceconf-flushcache-${host}":
  }
}
