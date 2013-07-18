# Class: ipa::master
#
# This class configures an IPA master
#
# Parameters:
#
# Actions:
#
# Requires: Exported resources, puppetlabs/puppetlabs-firewall, puppetlabs/stdlib
#
# Sample Usage:
#
class ipa::master (
  $svrpkg    = {},
  $dns       = {},
  $realm     = {},
  $domain    = {},
  $adminpw   = {},
  $dspw      = {},
  $sudo      = {},
  $sudopw    = {},
  $automount = {},
  $autofs    = {},
  $kstart    = {},
  $sssd      = {}
) {

  Ipa::Serverinstall[$::fqdn] -> Service['ipa'] -> Ipa::Hostadd <<| |>> -> Ipa::Replicareplicationfirewall <<| tag == "ipa-replica-replication-firewall-${ipa::master::domain}" |>> -> Ipa::Replicaprepare <<| tag == "ipa-replica-prepare-${ipa::master::domain}" |>>

  Ipa::Replicareplicationfirewall <<| tag == "ipa-replica-replication-firewall-${ipa::master::domain}" |>>
  Ipa::Replicaprepare <<| tag == "ipa-replica-prepare-${ipa::master::domain}" |>>
  Ipa::Hostadd <<| |>>

  if $ipa::master::sudo {
    Ipa::Configsudo <<| |>> {
      name    => $::fqdn,
      os      => "${::osfamily}${::lsbmajdistrelease}",
      require => Ipa::Serverinstall[$::fqdn]
    }
  }

  if $ipa::master::automount {
    Ipa::Configautomount <<| |>> {
      name    => $::fqdn,
      notify  => Service["autofs"],
      require => Ipa::Serverinstall[$::fqdn]
    }
  }

  if $ipa::master::autofs {
    realize Service["autofs"]
  }

  $principals = suffix(prefix([$::fqdn], "host/"), "@${ipa::master::realm}")

  if $::osfamily != 'RedHat' {
    fail("Cannot configure an IPA master server on ${::operatingsystem} operating systems. Must be a RedHat-like operating system.")
  }

  realize Package[$ipa::master::svrpkg]

  if $ipa::master::sssd {
    realize Service["sssd"]
  }

  if $ipa::master::kstart {
    realize Package["kstart"]
  }

  realize Service['ipa']

  $dnsopt = $ipa::master::dns ? {
    true    => '--setup-dns',
    default => ''
  }

  ipa::serverinstall { "$::fqdn":
    realm   => $ipa::master::realm,
    domain  => $ipa::master::domain,
    adminpw => $ipa::master::adminpw,
    dspw    => $ipa::master::dspw,
    dnsopt  => $ipa::master::dnsopt,
    require => Package[$ipa::master::svrpkg]
  }

  firewall { "101 allow IPA master TCP services (http,https,kerberos,kpasswd,ldap,ldaps)":
    ensure => 'present',
    action => 'accept',
    proto  => 'tcp',
    dport  => ['80','88','389','443','464','636']
  }

  firewall { "102 allow IPA master UDP services (kerberos,kpasswd,ntp)":
    ensure => 'present',
    action => 'accept',
    proto  => 'udp',
    dport  => ['88','123','464']
  }

  @@ipa::replicapreparefirewall { "$::fqdn":
    source => $::ipaddress,
    tag    => "ipa-replica-prepare-firewall-${ipa::master::domain}"
  }

  @@ipa::masterreplicationfirewall { "$::fqdn":
    source => $::ipaddress,
    tag    => "ipa-master-replication-firewall-${ipa::master::domain}"
  }

  @@ipa::masterprincipal { "$::fqdn":
    realm => $ipa::master::realm,
    tag   => "ipa-master-principal-${ipa::master::domain}"
  }

  @@ipa::clientinstall { "$::fqdn":
    masterfqdn => $::fqdn,
    domain     => $ipa::master::domain,
    realm      => $ipa::master::realm,
    adminpw    => $ipa::master::adminpw,
    otp        => '', 
    mkhomedir  => '', 
    ntp        => ''
  }

  if $ipa::master::sudo {
    @@ipa::configsudo { "$::fqdn":
      masterfqdn => $::fqdn,
      domain     => $ipa::master::domain,
      adminpw    => $ipa::master::adminpw,
      sudopw     => $ipa::master::sudopw
    }
  }

  if $ipa::master::automount {
    @@ipa::configautomount { "$::fqdn":
      masterfqdn => $::fqdn,
      domain     => $ipa::master::domain,
      realm      => $ipa::master::realm
    }
  }
}
