# Definition: snmpd::snmpv3_user
#
# Creates a SNMPv3 user.
#
# Parameters:
#   $authtype - optional - defaults to SHA|MD5
#   $authpass - required
#   $privtype - optional - defaults to AES|DES
#   $privpass - optional
#
# Actions:
#
# Requires:
#
# Sample Usage:
#  snmpd::snmpv3_user { "myuser":
#    authtype => "MD5",
#    authpass => '1234auth',
#    privpass => '5678priv',
#  }
#
define snmpd::snmpv3_user (
  $authtype = "SHA",
  $authpass,
  $privtype = "AES",
  $privpass = ""
) {
  if $privpass {
    $cmd = "createUser $title $authtype $authpass $privtype $privpass"
  } else {
    $cmd = "createUser $title $authtype $authpass"
  }
  exec { "create-snmpv3-user-${title}":
    path    => "/bin:/sbin:/usr/bin:/usr/sbin",
    command => "service snmpd stop ; echo \"$cmd\" >>${snmpd::params::var-net-snmp}/snmpd.conf && touch ${snmpd::params::var-net-snmp}/${title}",
    creates => "${snmpd::params::var-net-snmp}/${title}",
    user    => "root",
    require => [ Package["snmpd"], File["var-net-snmp"], ],
    before  => Service["snmpd"],
  }
}
