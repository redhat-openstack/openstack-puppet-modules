# == Definition: snmp::snmpv3_user
#
# This definition creates a SNMPv3 user.
#
# === Parameters:
#
# [*title*]
#   Name of the user.
#   Required
#
# [*authpass*]
#   Authentication password for the user.
#   Required
#
# [*authtype*]
#   Authentication type for the user.  SHA or MD5
#   Default: SHA
#
# [*privpass*]
#   Encryption password for the user.
#   Default: no encryption password
#
# [*privtype*]
#   Encryption type for the user.  AES or DES
#   Default: AES
#
# === Actions:
#
# Creates a SNMPv3 user with authentication and encryption paswords.
#
# === Requires:
#
# Class['snmp']
#
# === Sample Usage:
#
#   snmp::snmpv3_user { 'myuser':
#     authtype => 'MD5',
#     authpass => '1234auth',
#     privpass => '5678priv',
#   }
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2012 Mike Arnold, unless otherwise noted.
#
define snmp::snmpv3_user (
  $authpass,
  $authtype = 'SHA',
  $privpass = '',
  $privtype = 'AES'
) {
  include snmp::server

  if $privpass {
    $cmd = "createUser ${title} ${authtype} ${authpass} ${privtype} ${privpass}"
  } else {
    $cmd = "createUser ${title} ${authtype} ${authpass}"
  }
  exec { "create-snmpv3-user-${title}":
    path    => '/bin:/sbin:/usr/bin:/usr/sbin',
    # TODO: Add "rwuser ${title}" (or rouser) to /etc/snmp/snmpd.conf
    command => "service snmpd stop ; echo \"${cmd}\" >>${snmp::params::var_net_snmp}/snmpd.conf && touch ${snmp::params::var_net_snmp}/${title}",
    creates => "${snmp::params::var_net_snmp}/${title}",
    user    => 'root',
    require => [ Package['snmpd'], File['var-net-snmp'], ],
    before  => Service['snmpd'],
  }
}
