class snmpd::params {
  case $::operatingsystem {
    "RedHat", "CentOS", "Scientific", "SLC", "OracleLinux", "OVS", "OEL", "Amazon": {
      $package_name        = 'net-snmp'
      $client_package_name = 'net-snmp-utils'
      $client_config       = '/etc/snmp/snmp.conf'
      $service_config      = '/etc/snmp/snmpd.conf'
      $service_name        = 'snmpd'
      if $::lsbmajdistrelease <= "5" {
        $sysconfig         = '/etc/sysconfig/snmpd.options'
      } else {
        $sysconfig         = '/etc/sysconfig/snmpd'
      }
      $trap_service_config = '/etc/snmp/snmptrapd.conf'
      $trap_service_name   = 'snmptrapd'
      if $::lsbmajdistrelease <= "5" {
        $trap_sysconfig    = '/etc/sysconfig/snmptrapd.options'
      } else {
        $trap_sysconfig    = '/etc/sysconfig/snmptrapd'
      }
      $var-net-snmp        = '/var/net-snmp'
    }
    "Fedora", "Ascendos", "CloudLinux", "PSBM": {
      fail("${::hostname}: This module does not support operatingsystem ${::operatingsystem}")
    }
    default: {
      fail("${::hostname}: This module does not support operatingsystem ${::operatingsystem}")
    }
  }
}
