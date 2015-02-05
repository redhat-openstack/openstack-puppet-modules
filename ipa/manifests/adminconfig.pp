define ipa::adminconfig (
  $host    = $name,
  $idstart = {},
  $realm   = {},
) {

  $adminuidnumber = is_numeric($::ipa_adminuidnumber) ? {
    false   => $idstart,
    default => $::ipa_adminuidnumber
  }

  $adminhomedir = $::ipa_adminhomedir ? {
    ''   => '/home/admin',
    default => $::ipa_adminhomedir
  }

  k5login { "${adminhomedir}/.k5login":
    principals => $ipa::master::principals,
    notify     => File["${adminhomedir}/.k5login"],
    require    => File[$adminhomedir]
  }

  $kadminlocalcmd = shellquote('/usr/sbin/kadmin.local','-q',"ktadd -norandkey -k ${adminhomedir}/admin.keytab admin")
  $chownkeytabcmd = shellquote('/usr/bin/chown',"${adminuidnumber}:${adminuidnumber}","${adminhomedir}/admin.keytab")
  $k5startcmd = shellquote('/sbin/runuser','-l','admin','-c',"/usr/bin/k5start -f ${adminhomedir}/admin.keytab -U")

  exec { 'admin_keytab':
    command => "${kadminlocalcmd} && ${chownkeytabcmd} && ${k5startcmd} > /dev/null 2>&1",
    cwd     => $adminhomedir,
    unless  => shellquote('/usr/bin/kvno','-k',"${adminhomedir}/admin.keytab","admin@${realm}"),
    notify  => File["${adminhomedir}/admin.keytab"],
    require => Cron['k5start_admin']
  }

  cron { 'k5start_admin':
    command => "/usr/bin/k5start -f ${adminhomedir}/admin.keytab -U > /dev/null 2>&1",
    user    => 'admin',
    minute  => '*/1',
    require => [Package['kstart'], K5login["${adminhomedir}/.k5login"], File[$adminhomedir]]
  }

  file { $adminhomedir:
    ensure  => directory,
    mode    => '0700',
    owner   => $adminuidnumber,
    group   => $adminuidnumber,
    recurse => true,
    notify  => Exec['admin_keytab'],
    require => Exec["serverinstall-${host}"]
  }

  file { "${adminhomedir}/.k5login":
    owner   => $adminuidnumber,
    group   => $adminuidnumber,
    require => File[$adminhomedir]
  }

  file { "${adminhomedir}/admin.keytab":
    owner   => $adminuidnumber,
    group   => $adminuidnumber,
    mode    => '0600',
    require => File[$adminhomedir]
  }
}
