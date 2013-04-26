# Class: ipa::replica
#
# This class configures an IPA replica
#
# Parameters:
#
# Actions:
#
# Requires: Exported resources, puppetlabs/puppetlabs-firewall
#
# Sample Usage:
#
class ipa::replica (
  $svrpkg = {},
  $adminpw = {},
  $dspw = {},
  $kstart = {}
) {

  Class['ipa::client'] -> Ipa::Masterprincipal <<| tag == 'ipa-master-principal' |>> -> Ipa::Replicainstall[$::fqdn] -> Ipa::Replicapreparefirewall <<| tag == 'ipa-replica-prepare-firewall' |>> -> Ipa::Masterreplicationfirewall <<| tag == 'ipa-master-replication-firewall' |>> -> Service['ipa']

  Ipa::Replicapreparefirewall <<| tag == 'ipa-replica-prepare-firewall' |>>
  Ipa::Masterreplicationfirewall <<| tag == 'ipa-master-replication-firewall' |>>
  Ipa::Masterprincipal <<| tag == 'ipa-master-principal' |>>

  if $::osfamily != "RedHat" {
    fail("Cannot configure an IPA replica server on ${::operatingsystem} operating systems. Must be a RedHat-like operating system.") 
  }

  realize Package[$ipa::replica::svrpkg] 

  if $ipa::replica::kstart { 
    realize Package["kstart"]
  }

  realize Service['ipa']

  firewall {
    "101 allow IPA replica TCP services (kerberos,kpasswd,ldap,ldaps)":
      ensure => 'present',
      action => 'accept',
      proto  => 'tcp',
      dport  => ['88','389','464','636'];

    "102 allow IPA replica UDP services (kerberos,kpasswd,ntp)":
      ensure => 'present',
      action => 'accept',
      proto  => 'udp',
      dport  => ['88','123','464'];
  }

  ipa::replicainstall {
    "$::fqdn":
      adminpw => $ipa::replica::adminpw,
      dspw    => $ipa::replica::dspw,
      require => Package[$ipa::replica::svrpkg];
  }

  @@ipa::replicareplicationfirewall {
    "$::fqdn":
      source => $::ipaddress,
      tag    => "ipa-replica-replication-firewall";
  }

  @@ipa::replicaprepare {
    "$::fqdn":
      dspw => $ipa::replica::dspw,
      tag  => "ipa-replica-prepare";
  }
}
