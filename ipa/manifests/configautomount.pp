define ipa::configautomount (
  $host       = $name,
  $os         = {},
  $domain     = {},
  $realm      = {},
  $masterfqdn = {}
) {

  Augeas["nsswitch-automount-${host}"] -> Augeas["sysconfig-autofs-${name}"] -> File["autofs_ldap_auth-${host}"]

  $dc = prefix([regsubst($domain,'(\.)',',dc=','G')],'dc=')

  $autofspath = $os ? {
    Debian  => '/etc/default/autofs',
    default => '/etc/sysconfig/autofs'
  }

  augeas { "nsswitch-automount-${host}":
    context => '/files/etc/nsswitch.conf',
    changes => [
      'set database[. = "automount"] automount',
      'set database[. = "automount"]/service[1] files',
      'set database[. = "automount"]/service[2] ldap',
    ]
  }

  augeas { "sysconfig-autofs-${name}":
    context => $autofspath,
    changes => [
      'set MAP_OBJECT_CLASS automountMap',
      'set ENTRY_OBJECT_CLASS automount',
      'set MAP_ATTRIBUTE automountMapName',
      'set ENTRY_ATTRIBUTE automountKey',
      'set VALUE_ATTRIBUTE automountInformation',
      "set LDAP_URI ldap://${masterfqdn}",
      "set SEARCH_BASE cn=default,cn=automount,${dc}"
    ]
  }

  file { "autofs_ldap_auth-${host}":
    path    => '/etc/autofs_ldap_auth.conf',
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => template('ipa/autofs_ldap_auth.conf.erb')
  }
}
