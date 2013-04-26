# == Class: ipa
#
# Configures IPA masters, replicas and clients.
#
# === Parameters
#
#  $master = false - Configures a server to be an IPA master LDAP/Kerberos node.
#  $replica = false - Configures a server to be an IPA replica LDAP/Kerberos node.
#  $client = false - Configures a server to be an IPA client.
#  $cleanup = false - Removes IPA specific packages.
#  $domain = {} - Defines the LDAP domain.
#  $realm = {} - Defines the Kerberos realm.
#  $adminpw = {} - Defines the IPA administrative user password.
#  $dspw = {} - Defines the IPA directory services password.
#  $otp = {} - Defines an IPA client one-time-password.
#  $dns = false - Controls the option to configure a DNS zone with the IPA master setup.
#  $mkhomedir = false - Controls the option to create user home directories on first login.
#  $ntp = false - Controls the option to configure NTP on a client.
#  $kstart = true - Controls the installation of kstart.
#  $desc = '' - Controls the description entry of an IPA client.
#  $locality = '' - Controls the locality entry of an IPA client.
#  $location = '' - Controls the location entry of an IPA client.
#  $svrpkg = "ipa-server" - IPA server package.
#  $clntpkg = "ipa-client" - IPA client package.
#
# === Variables
#
#
# === Examples
#
#
# === Authors
#
#
# === Copyright
#
#
class ipa (
  $master = $ipa::params::master,
  $replica = $ipa::params::replica,
  $client = $ipa::params::client,
  $cleanup = $ipa::params::cleanup,
  $domain = downcase($ipa::params::domain),
  $realm = upcase($ipa::params::realm),
  $adminpw = $ipa::params::adminpw,
  $dspw = $ipa::params::dspw,
  $otp = $ipa::params::otp,
  $dns = $ipa::params::dns,
  $mkhomedir = $ipa::params::mkhomedir,
  $ntp = $ipa::params::ntp,
  $kstart = $ipa::params::kstart,
  $desc = $ipa::params::desc,
  $locality = $ipa::params::locality,
  $location = $ipa::params::location,
  $svrpkg = $ipa::params::svrpkg,
  $clntpkg = $ipa::params::clntpkg
) inherits ipa::params {

  @package {
    $ipa::svrpkg:
      ensure => installed;
    $ipa::clntpkg:
      ensure => installed;
  }

  if $ipa::kstart {
    @package {
      "kstart":
        ensure => installed;
    }
  }

  @service {
    "ipa":
      ensure  => 'running',
      require => Package[$ipa::svrpkg];
  }

  validate_re("$ipa::adminpw",'^.........*$',"Parameter 'adminpw' must be at least 8 characters long")
  validate_re("$ipa::dspw",'^.........*$',"Parameter 'dspw' must be at least 8 characters long")

  if is_domain_name($ipa::domain) == false {
    fail("Parameter 'domain' is not a valid domain name")
  }
  if is_domain_name($ipa::realm) == false {
    fail("Parameter 'realm' is not a valid domain name")
  }

  if $ipa::cleanup == true {
    if $ipa::master == true or $ipa::replica == true or $ipa::client == true {
      fail("Conflicting options selected. Cannot cleanup during an installation.")
    } else {
      ipa::cleanup {
        "$fqdn":
          svrpkg  => $ipa::svrpkg,
          clntpkg => $ipa::clntpkg;
      }
    }
  }

  if $ipa::master == true {
    class {
      "ipa::master":
        svrpkg      => $ipa::svrpkg,
        dns         => $ipa::dns,
        domain      => $ipa::domain,
        realm       => $ipa::realm,
        adminpw     => $ipa::adminpw,
        dspw        => $ipa::dspw,
        kstart      => $ipa::kstart;
    }
    if $ipa::domain == false {
      fail("Required parameter 'domain' missing")
    }
    if $ipa::realm == false {
      fail("Required parameter 'realm' missing")
    }
    if $ipa::adminpw == false {
      fail("Required parameter 'adminpw' missing")
    }
    if $ipa::dspw == false {
      fail("Required parameter 'dspw' missing")
    }
  }

  if $ipa::replica == true {
    class {
      "ipa::replica":
        svrpkg    => $ipa::svrpkg,
        adminpw   => $ipa::adminpw,
        dspw      => $ipa::dspw,
        kstart    => $ipa::kstart;
      "ipa::client":
        clntpkg   => $ipa::clntpkg,
        domain    => $ipa::domain,
        realm     => $ipa::realm,
        otp       => $ipa::otp,
        mkhomedir => $ipa::mkhomedir,
        ntp       => $ipa::ntp,
        desc      => $ipa::desc,
        locality  => $ipa::locality,
        location  => $ipa::location;
    }
    if $ipa::adminpw == false {
      fail("Required parameter 'adminpw' missing")
    }
    if $ipa::dspw == false {
      fail("Required parameter 'dspw' missing")
    }
    if $ipa::domain == false {
      fail("Required parameter 'domain' missing")
    }
    if $ipa::realm == false {
      fail("Required parameter 'realm' missing")
    }
    if $ipa::otp == false {
      fail("Required parameter 'otp' missing")
    }
  }

  if $ipa::client == true {
    class {
      "ipa::client":
        clntpkg   => $ipa::clntpkg,
        domain    => $ipa::domain,
        realm     => $ipa::realm,
        otp       => $ipa::otp,
        mkhomedir => $ipa::mkhomedir,
        ntp       => $ipa::ntp,
        desc      => $ipa::desc,
        locality  => $ipa::locality,
        location  => $ipa::location;
    }
    if $ipa::domain == false {
      fail("Required parameter 'domain' missing")
    }
    if $ipa::realm == false {
      fail("Required parameter 'realm' missing")
    }
    if $ipa::otp == false {
      fail("Required parameter 'otp' missing")
    }
  }
}
