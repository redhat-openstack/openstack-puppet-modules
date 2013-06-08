define ipa::serverinstall (
  $host    = $name,
  $realm   = {},
  $domain  = {},
  $adminpw = {},
  $dspw    = {},
  $dnsopt  = {}
) {

  exec { "serverinstall-${host}":
    command   => "/usr/sbin/ipa-server-install --hostname=${host} --realm=${realm} --domain=${domain} --admin-password=${adminpw} --ds-password=${dspw} ${dnsopt} --unattended",
    timeout   => '0',
    unless    => "/usr/sbin/ipactl status >/dev/null 2>&1",
    creates   => "/etc/ipa/default.conf",
    notify    => Ipa::Flushcache["server-${host}"],
    logoutput => "on_failure"
  }<- notify { "Running IPA server install, please wait.": }

  ipa::flushcache { "server-${host}":
    notify => Ipa::Puppetrunin1min["serverinstall"],
  }

  ipa::puppetrunin1min { "serverinstall":
  }

  if $::ipaadminhomedir and is_numeric($::ipaadminuidnumber) {
    k5login { "${::ipaadminhomedir}/.k5login":
      principals => $ipa::master::principals,
      notify     => File["${::ipaadminhomedir}/.k5login"],
      require    => File["${::ipaadminhomedir}"]
    }

    exec { "admin_keytab":
      command     => "/usr/sbin/kadmin.local -q 'ktadd -norandkey -k admin.keytab admin'",
      cwd         => "${::ipaadminhomedir}",
      creates     => "${::ipaadminhomedir}/admin.keytab",
      notify      => File["${::ipaadminhomedir}/admin.keytab"],
      require     => [File["${::ipaadminhomedir}"], K5login["${::ipaadminhomedir}/.k5login"]]
    }

    cron { "k5start_admin":
      command => "/usr/bin/k5start -f ${::ipaadminhomedir}/admin.keytab -U -o admin -k /tmp/krb5cc_${::ipaadminuidnumber} > /dev/null 2>&1",
      user    => 'root',
      minute  => "*/1",
      require => [Package["kstart"], K5login["${::ipaadminhomedir}/.k5login"], File["$::ipaadminhomedir"]]
    }

    file { "$::ipaadminhomedir":
      ensure  => directory,
      mode    => '700',
      owner   => $::ipaadminuidnumber,
      group   => $::ipaadminuidnumber,
      recurse => true,
      notify  => Exec["admin_keytab"],
      require => Exec["serverinstall-${host}"]
    }

    file { "${::ipaadminhomedir}/.k5login":
      owner   => $::ipaadminuidnumber,
      group   => $::ipaadminuidnumber,
      require => File[$::ipaadminhomedir]
    }

    file { "${::ipaadminhomedir}/admin.keytab":
      owner   => $::ipaadminuidnumber,
      group   => $::ipaadminuidnumber,
      mode    => '600',
      require => File[$::ipaadminhomedir]
    }
  }
}
