# Class: snmpd
#
# This class manages snmpd.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class snmpd {
  include snmpd::params

  package { 'snmpd':
    ensure => 'present',
    name   => $snmpd::params::package_name,
  }

  file { 'snmpd.conf':
    ensure  => 'present',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    path    => $snmpd::params::service_config,
    source  => [
      "puppet:///modules/snmpd/snmpd.conf.${::fqdn}",
      "puppet:///modules/snmpd/snmpd.conf.${::osfamily}",
      'puppet:///modules/snmpd/snmpd.conf',
    ],
    require => Package['snmpd'],
    notify  => Service['snmpd'],
  }

  file { 'snmpd.sysconfig':
    ensure  => 'present',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    path    => $snmpd::params::sysconfig,
    source  => [
      "puppet:///modules/snmpd/snmpd.sysconfig.${::fqdn}",
      "puppet:///modules/snmpd/snmpd.sysconfig.${::osfamily}",
      'puppet:///modules/snmpd/snmpd.sysconfig',
    ],
    require => Package['snmpd'],
    notify  => Service['snmpd'],
  }

  file { 'var-net-snmp':
    ensure  => 'directory',
    mode    => '0700',
    owner   => 'root',
    group   => 'root',
    path    => $snmpd::params::var_net_snmp,
    require => Package['snmpd'],
  }

  service { 'snmpd':
    ensure     => 'running',
    name       => $snmpd::params::service_name,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Package['snmpd'],
  }
}
