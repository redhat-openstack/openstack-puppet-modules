# Class: snmpd::client
#
# This class manages SNMP client tools.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class snmpd::client {
  include snmpd::params

  package { 'snmp-client':
    ensure => 'present',
    name   => $snmpd::params::client_package_name,
  }

  file { 'snmp.conf':
    ensure  => 'present',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    path    => $snmpd::params::client_config,
    source  => [
      "puppet:///modules/snmpd/snmp.conf.${::fqdn}",
      "puppet:///modules/snmpd/snmp.conf.${::osfamily}",
      'puppet:///modules/snmpd/snmp.conf',
    ],
    require => Package['snmpd'],
  }
}
