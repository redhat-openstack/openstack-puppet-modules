# Class: snmpd::disable
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
class snmpd::disable inherits snmpd {
  Service["snmpd"] {
    ensure => "stopped",
    enable => "false",
  }
}
