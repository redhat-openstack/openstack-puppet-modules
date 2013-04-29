# == Class: ipa::params
#
# Defaults for ipa class.
#
# === Parameters
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
class ipa::params {
  $master = false
  $replica = false
  $client = false
  $cleanup = false
  $domain = false
  $realm = false
  $adminpw = false
  $dspw = false
  $otp = false
  $dns = false
  $mkhomedir = false
  $ntp = false
  $kstart = true
  $desc = ''
  $locality = ''
  $location = ''
  $sssdtools = 'sssd-tools'
  $sssd = true
  $svrpkg = 'ipa-server'
  $clntpkg = $::osfamily ? {
    Debian  => 'freeipa-client',
    default => 'ipa-client',
  }
  $ldaputils = $::osfamily ? {
    Debian  => 'ldap-utils',
    default => 'openldap-clients',
  }
}
