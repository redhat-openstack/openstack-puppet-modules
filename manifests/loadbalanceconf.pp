define ipa::loadbalanceconf (
  $host       = $name,
  $domain     = {},
  $ipaservers = [],
  $mkhomedir  = {}
) {

  Exec["loadbalanceconf-authconfig-${host}"] ~> Ipa::Flushcache["loadbalanceconf-flushcache-${host}"]

  $dc = prefix([regsubst($domain,'(\.)',',dc=','G')],'dc=')

  $servers = chop(inline_template('<% @ipaservers.each do |@ipaserver| -%><%= @ipaserver %>,<% end -%>'))

  case $::osfamily {
    'Debian': {
      notify { "Unable to configure load balanced IPA directory services for Debian.": }
    }
    'default': {
      $mkhomediropt = $mkhomedir ? {
        true    => '--enablemkhomedir',
        default => ''
      }

      exec { "loadbalanceconf-authconfig-${host}":
        command     => "/usr/sbin/authconfig --ldapserver=${servers} --ldapbasedn=${dc} --krb5kdc=${servers} --krb5adminserver=${servers} ${mkhomediropt} --update",
        logoutput   => "on_failure"
      }<- notify { "Addling load balanced IPA directory services, please wait.": }
    }
  }

  ipa::flushcache { "loadbalanceconf-flushcache-${host}":
  }
}
