# Class: snmpd::trapd::disable
#
# This class handles disabling the SNMP daemon.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class snmpd::trapd::disable inherits snmpd::trapd {
  Service['snmptrapd'] {
    ensure => 'stopped',
    enable => false,
  }
}
