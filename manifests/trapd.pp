# Class: snmpd::trapd
#
# This class manages snmptrapd.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class snmpd::trapd {
  include snmpd

  file { 'snmptrapd.conf':
    ensure  => 'present',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    path    => $snmpd::params::trap_service_config,
    source  => [
      "puppet:///modules/snmpd/snmptrapd.conf.${::fqdn}",
      "puppet:///modules/snmpd/snmptrapd.conf.${::osfamily}",
      'puppet:///modules/snmpd/snmptrapd.conf',
    ],
    require => Package['snmpd'],
    notify  => Service['snmptrapd'],
  }

  file { 'snmptrapd.sysconfig':
    ensure  => 'present',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    path    => $snmpd::params::trap_sysconfig,
    source  => [
      "puppet:///modules/snmpd/snmptrapd.sysconfig.${::fqdn}",
      "puppet:///modules/snmpd/snmptrapd.sysconfig.${::osfamily}",
      'puppet:///modules/snmpd/snmptrapd.sysconfig',
    ],
    require => Package['snmpd'],
    notify  => Service['snmptrapd'],
  }

  service { 'snmptrapd':
    ensure     => 'running',
    name       => $snmpd::params::trap_service_name,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Package['snmpd'],
  }
}
