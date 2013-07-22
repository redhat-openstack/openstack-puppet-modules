# Class: ipa::client
#
# This class configures an IPA client
#
# Parameters:
#
# Actions:
#
# Requires: Exported resources, puppetlabs/puppetlabs-firewall, puppetlabs/stdlib
#
# Sample Usage:
#
class ipa::client (
  $clntpkg       = {},
  $ldaputils     = {},
  $ldaputilspkg  = {},
  $sssdtools     = {},
  $sssdtoolspkg  = {},
  $sssd          = {},
  $client        = {},
  $domain        = {},
  $realm         = {},
  $sudo          = {},
  $debiansudopkg = {},
  $automount     = {},
  $autofs        = {},
  $otp           = {},
  $ipaservers    = [],
  $loadbalance   = {},
  $mkhomedir     = false,
  $ntp           = false,
  $desc          = {},
  $locality      = {},
  $location      = {}
) {

  Ipa::Clientinstall <<| |>> {
    name      => $::fqdn,
    otp       => $ipa::client::otp,
    domain    => $ipa::client::domain,
    mkhomedir => $ipa::client::mkhomedir,
    ntp       => $ipa::client::ntp,
    require   => Package[$ipa::client::clntpkg]
  }

  if $ipa::client::sudo {
    Ipa::Configsudo <<| |>> {
      name    => $::fqdn,
      os      => "${::osfamily}${::lsbmajdistrelease}",
      require => Ipa::Clientinstall[$::fqdn]
    }
  }

  if $ipa::client::automount {
    Ipa::Configautomount <<| |>> {
      name    => $::fqdn,
      os      => $::osfamily,
      notify  => Service["autofs"],
      require => Ipa::Clientinstall[$::fqdn]
    }
  }

  if $ipa::client::autofs {
    realize Service["autofs"]
  }

  if defined(Package[$ipa::client::clntpkg]) {
    realize Package["$ipa::client::clntpkg"]
  }

  if $ipa::client::ldaputils {
    if defined(Package[$ipa::client::ldaputilspkg]) {
      realize Package["$ipa::client::ldaputilspkg"]
    }
  }

  if $ipa::client::sssdtools {
    if defined(Package[$ipa::client::sssdtoolspkg]) {
      realize Package["$ipa::client::sssdtoolspkg"]
    }
  }

  if $ipa::client::sssd {
    realize Service["sssd"]
  }

  if $::osfamily == 'Debian' {
    file { "/etc/pki":
      ensure  => directory,
      mode    => 755,
      owner   => root,
      group   => root,
      require => Package[$ipa::client::clntpkg]
    }

    file {"/etc/pki/nssdb":
      ensure  => directory,
      mode    => 755,
      owner   => root,
      group   => root,
      require => File["/etc/pki"]
    }

    File["/etc/pki/nssdb"] -> Ipa::Clientinstall <<| |>>

    if $ipa::client::sudo and $ipa::client::debiansudopkg {
      @package { 'sudo-ldap':
        ensure => installed
      }
      realize Package['sudo-ldap']
    }
  }

  @@ipa::hostadd { "$::fqdn":
    otp      => $ipa::client::otp,
    desc     => $ipa::client::desc,
    clientos => $::lsbdistdescription,
    clientpf => $::manufacturer,
    locality => $ipa::client::locality,
    location => $ipa::client::location
  }

  if $ipa::client::loadbalance {
    ipa::loadbalanceconf { "client-${::fqdn}":
      domain     => $ipa::client::domain,
      ipaservers => $ipa::client::ipaservers,
      mkhomedir  => $ipa::client::mkhomedir,
      require    => Ipa::Clientinstall[$::fqdn]
    }
  }
}
