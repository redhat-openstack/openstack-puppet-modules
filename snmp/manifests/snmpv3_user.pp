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
# [*daemon*]
#   Which daemon file in which to write the user.  snmpd or snmptrapd
#   Default: snmpd
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
  $privtype = 'AES',
  $daemon   = 'snmpd'
) {
  # Validate our regular expressions
  $hash_options = [ '^SHA$', '^MD5$' ]
  validate_re($authtype, $hash_options, '$authtype must be either SHA or MD5.')
  $enc_options = [ '^AES$', '^DES$' ]
  validate_re($privtype, $enc_options, '$privtype must be either AES or DES.')
  $daemon_options = [ '^snmpd$', '^snmptrapd$' ]
  validate_re($daemon, $daemon_options, '$daemon must be either snmpd or snmptrapd.')

  include snmp

  if ($daemon == 'snmptrapd') and ($::osfamily != 'Debian') {
    $service_name   = 'snmptrapd'
    $service_before = Service['snmptrapd']
  } else {
    $service_name   = 'snmpd'
    $service_before = Service['snmpd']
  }

  if $privpass {
    $cmd = "createUser ${title} ${authtype} ${authpass} ${privtype} ${privpass}"
  } else {
    $cmd = "createUser ${title} ${authtype} ${authpass}"
  }
  exec { "create-snmpv3-user-${title}":
    path    => '/bin:/sbin:/usr/bin:/usr/sbin',
    # TODO: Add "rwuser ${title}" (or rouser) to /etc/snmp/${daemon}.conf
    command => "service ${service_name} stop ; echo \"${cmd}\" >>${snmp::params::var_net_snmp}/${daemon}.conf && touch ${snmp::params::var_net_snmp}/${title}-${daemon}",
    creates => "${snmp::params::var_net_snmp}/${title}-${daemon}",
    user    => 'root',
    require => [ Package['snmpd'], File['var-net-snmp'], ],
    before  => $service_before,
  }
}
