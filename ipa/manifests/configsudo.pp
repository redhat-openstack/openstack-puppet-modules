# Definition: ipa::configsudo
#
# Configures sudoers in LDAP
define ipa::configsudo (
  $host       = $name,
  $os         = {},
  $sudopw     = {},
  $adminpw    = {},
  $domain     = {},
  $masterfqdn = {}
) {

  Augeas["nsswitch-sudoers-${host}"] -> Exec["set-sudopw-${host}"]

  $dc = prefix([regsubst($domain,'(\.)',',dc=','G')],'dc=')

  augeas { "nsswitch-sudoers-${host}":
    context => '/files/etc/nsswitch.conf',
    changes => [
      'set database[. = "sudoers"] sudoers',
      'set database[. = "sudoers"]/service[1] files',
      'set database[. = "sudoers"]/service[2] ldap'
    ]
  }

  if $os == 'RedHat5' {
    augeas { "sudo-ldap-rhel5-${host}":
      context => '/files/etc/ldap.conf',
      changes => [
        "set binddn uid=sudo,cn=sysaccounts,cn=etc,${dc}",
        "set bindpw ${sudopw}",
        'set ssl start_tls',
        'set tls_cacertfile /etc/ipa/ca.crt',
        'set tls_checkpeer yes',
        'set bind_timelimit 5',
        'set timelimit 15',
        "set sudoers_base ou=sudoers,${dc}"
      ]
    }
  } else {
    file { "sudo-ldap-${host}":
      path    => '/etc/sudo-ldap.conf',
      owner   => 'root',
      group   => 'root',
      mode    => '0640',
      content => template('ipa/sudo-ldap.conf.erb')
    }
  }

  exec { "set-sudopw-${host}":
    command   => "/bin/bash -c \"LDAPTLS_REQCERT=never /usr/bin/ldappasswd -x -H ldaps://${masterfqdn} -D uid=admin,cn=users,cn=accounts,${dc} -w ${adminpw} -s ${sudopw} uid=sudo,cn=sysaccounts,cn=etc,${dc}\"",
    unless    => "/bin/bash -c \"LDAPTLS_REQCERT=never /usr/bin/ldapsearch -x -H ldaps://${masterfqdn} -D uid=sudo,cn=sysaccounts,cn=etc,${dc} -w ${sudopw} -b cn=sysaccounts,cn=etc,${dc} uid=sudo\"",
    onlyif    => '/usr/sbin/ipactl status >/dev/null 2>&1',
    logoutput => 'on_failure'
  }

  exec { "setupnisdomain-${host}":
    command => "/bin/nisdomainname ${domain}",
    unless  => "/usr/bin/test $(/bin/nisdomainname) = ${domain}",
    require => Exec["set-sudopw-${host}"]
  }
}
