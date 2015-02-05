# Definition: ipa::loadbalanceconf
#
# Configures IPA load balancing
define ipa::loadbalanceconf (
  $host       = $name,
  $domain     = {},
  $ipaservers = [],
  $mkhomedir  = {}
) {

  $dc = prefix([regsubst($domain,'(\.)',',dc=','G')],'dc=')

  $servers = chop(inline_template('<% @ipaservers.each do |ipaserver| -%><%= ipaserver %>,<% end -%>'))

  case $::osfamily {
    'Debian': {
      notify { 'Unable to configure load balanced IPA directory services for Debian.': }
    }
    default: {
      $mkhomediropt = $mkhomedir ? {
        true    => '--enablemkhomedir',
        default => ''
      }

      exec { "loadbalanceconf-authconfig-${host}":
        command     => "/usr/sbin/authconfig --nostart --enablesssd --enableldap --ldapserver=${servers} --ldapbasedn=${dc} --krb5kdc=${servers} --krb5adminserver=${servers} ${mkhomediropt} --update",
        logoutput   => 'on_failure'
      } ~> Ipa::Flushcache["loadbalanceconf-flushcache-${host}"]
    }
  }

  ipa::flushcache { "loadbalanceconf-flushcache-${host}":
  }
}
