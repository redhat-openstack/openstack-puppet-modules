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
  $svrpkg        = {},
  $dns           = {},
  $forwarders    = [],
  $realm         = {},
  $domain        = {},
  $ipaservers    = [],
  $loadbalance   = {},
  $adminpw       = {},
  $dspw          = {},
  $sudo          = {},
  $sudopw        = {},
  $automount     = {},
  $autofs        = {},
  $kstart        = {},
  $sssd          = {},
  $ntp           = {},
  $extca         = {},
  $extcertpath   = {},
  $extcert       = {},
  $extcacertpath = {},
  $extcacert     = {},
  $dirsrv_pkcs12 = {},
  $http_pkcs12   = {},
  $dirsrv_pin    = {},
  $http_pin      = {},
  $subject       = {},
  $selfsign      = {},
  $idstart       = {}
) {

  Ipa::Serverinstall[$::fqdn] ->  File['/etc/ipa/primary'] -> Ipa::Hostadd <<| |>> -> Ipa::Replicareplicationfirewall <<| tag == "ipa-replica-replication-firewall-${ipa::master::domain}" |>> -> Ipa::Replicaprepare <<| tag == "ipa-replica-prepare-${ipa::master::domain}" |>> -> Ipa::Createreplicas[$::fqdn]

  Ipa::Replicareplicationfirewall <<| tag == "ipa-replica-replication-firewall-${ipa::master::domain}" |>>
  Ipa::Replicaprepare <<| tag == "ipa-replica-prepare-${ipa::master::domain}" |>>
  Ipa::Hostadd <<| |>>

  file { '/etc/ipa/primary':
    ensure  => 'file',
    content => 'Added by HUIT IPA Puppet module: designates primary master - do not remove.'
  }

  if $ipa::master::sudo {
    Ipa::Configsudo <<| |>> {
      name    => $::fqdn,
      os      => "${::osfamily}${::lsbmajdistrelease}",
      require => Ipa::Serverinstall[$::fqdn]
    }
  }

  if $ipa::master::automount {
    if $ipa::master::autofs {
      realize Service['autofs']
      realize Package['autofs']
    }

    Ipa::Configautomount <<| |>> {
      name    => $::fqdn,
      os      => $::osfamily,
      notify  => Service['autofs'],
      require => Ipa::Serverinstall[$::fqdn]
    }
  }

  $principals = suffix(prefix([$::fqdn], 'host/'), "@${ipa::master::realm}")

  if $::osfamily != 'RedHat' {
    fail("Cannot configure an IPA master server on ${::operatingsystem} operating systems. Must be a RedHat-like operating system.")
  }

  realize Package[$ipa::master::svrpkg]

  if $ipa::master::sssd {
    realize Package['sssd-common']
    realize Service['sssd']
  }

  if $ipa::master::kstart {
    realize Package['kstart']
  }

  if $ipa::master::dns {
    if size($ipa::master::forwarders) > 0 {
      $forwarderopts = join(prefix($ipa::master::forwarders, '--forwarder '), ' ')
    }
    else {
      $forwarderopts = '--no-forwarders'
    }
    $dnsopt = '--setup-dns'
    realize Package['bind-dyndb-ldap']
  }
  else {
    $dnsopt = ''
    $forwarderopts = ''
  }

  $ntpopt = $ipa::master::ntp ? {
    false   => '--no-ntp',
    default => ''
  }

  $extcaopt = $extca ? {
    true    => '--external-ca',
    default => ''
  }

  $random_idstart = fqdn_rand('10737') + 10000

  $generated_idstart = $idstart ? {
    false => $random_idstart,
    default => $idstart,
  }

  ipa::serverinstall { $::fqdn:
    realm         => $ipa::master::realm,
    domain        => $ipa::master::domain,
    adminpw       => $ipa::master::adminpw,
    dspw          => $ipa::master::dspw,
    dnsopt        => $ipa::master::dnsopt,
    forwarderopts => $ipa::master::forwarderopts,
    ntpopt        => $ipa::master::ntpopt,
    extcaopt      => $ipa::master::extcaopt,
    idstart       => $ipa::master::generated_idstart,
    require       => Package[$ipa::master::svrpkg]
  }

  if $extca {
    class { 'ipa::master_extca':
      extcertpath   => $ipa::master::extcertpath,
      extcert       => $ipa::master::extcert,
      extcacertpath => $ipa::master::extcacertpath,
      extcacert     => $ipa::master::extcacert,
      dirsrv_pkcs12 => $ipa::master::dirsrv_pkcs12,
      http_pkcs12   => $ipa::master::http_pkcs12,
      dirsrv_pin    => $ipa::master::dirsrv_pin,
      http_pin      => $ipa::master::http_pin,
      subject       => $ipa::master::subject,
      selfsign      => $ipa::master::selfsign,
      require       => Ipa::Serverinstall[$::fqdn]
    }
  } else {
    class { 'ipa::service':
      require => Ipa::Serverinstall[$::fqdn]
    }
  }

  ipa::createreplicas { $::fqdn:
  }

  firewall { '101 allow IPA master TCP services (http,https,kerberos,kpasswd,ldap,ldaps)':
    ensure => 'present',
    action => 'accept',
    proto  => 'tcp',
    dport  => ['80','88','389','443','464','636']
  }

  firewall { '102 allow IPA master UDP services (kerberos,kpasswd,ntp)':
    ensure => 'present',
    action => 'accept',
    proto  => 'udp',
    dport  => ['88','123','464']
  }

  @@ipa::replicapreparefirewall { $::fqdn:
    source => $::ipaddress,
    tag    => "ipa-replica-prepare-firewall-${ipa::master::domain}"
  }

  @@ipa::masterreplicationfirewall { $::fqdn:
    source => $::ipaddress,
    tag    => "ipa-master-replication-firewall-${ipa::master::domain}"
  }

  @@ipa::masterprincipal { $::fqdn:
    realm => $ipa::master::realm,
    tag   => "ipa-master-principal-${ipa::master::domain}"
  }

  @@ipa::clientinstall { $::fqdn:
    masterfqdn => $::fqdn,
    domain     => $ipa::master::domain,
    realm      => $ipa::master::realm,
    adminpw    => $ipa::master::adminpw,
    otp        => '',
    mkhomedir  => '',
    ntp        => ''
  }

  if $ipa::master::sudo {
    @@ipa::configsudo { $::fqdn:
      masterfqdn => $::fqdn,
      domain     => $ipa::master::domain,
      adminpw    => $ipa::master::adminpw,
      sudopw     => $ipa::master::sudopw
    }
  }

  if $ipa::master::automount {
    @@ipa::configautomount { $::fqdn:
      masterfqdn => $::fqdn,
      os         => $::osfamily,
      domain     => $ipa::master::domain,
      realm      => $ipa::master::realm
    }
  }

  if $ipa::master::loadbalance {
    ipa::loadbalanceconf { "master-${::fqdn}":
      domain     => $ipa::master::domain,
      ipaservers => $ipa::master::ipaservers,
      mkhomedir  => $ipa::master::mkhomedir,
      require    => Ipa::Serverinstall[$::fqdn]
    }
  }
}
