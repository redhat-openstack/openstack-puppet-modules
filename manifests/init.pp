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

  package { "snmpd":
    ensure => "present",
    name   => $snmpd::params::package_name,
  }

  file { "snmpd.conf":
    mode    => "644",
    owner   => "root",
    group   => "root",
    ensure  => "present",
    path    => $snmpd::params::service_config,
    source  => [
      "puppet:///modules/snmpd/snmpd.conf.${::fqdn}",
      "puppet:///modules/snmpd/snmpd.conf.${::osfamily}",
      "puppet:///modules/snmpd/snmpd.conf",
    ],
    require => Package["snmpd"],
    notify  => Service["snmpd"],
  }

  file { "snmpd.sysconfig":
    mode    => "644",
    owner   => "root",
    group   => "root",
    ensure  => "present",
    path    => $snmpd::params::sysconfig,
    source  => [
      "puppet:///modules/snmpd/snmpd.sysconfig.${::fqdn}",
      "puppet:///modules/snmpd/snmpd.sysconfig.${::osfamily}",
      "puppet:///modules/snmpd/snmpd.sysconfig",
    ],
    require => Package["snmpd"],
    notify  => Service["snmpd"],
  }

  file { "var-net-snmp":
    mode    => "700",
    owner   => "root",
    group   => "root",
    ensure  => "directory",
    path    => $snmpd::params::var_net_snmp,
    require => Package["snmpd"],
  }

  service { "snmpd":
    name       => $snmpd::params::service_name,
    ensure     => "running",
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Package["snmpd"],
  }
}
