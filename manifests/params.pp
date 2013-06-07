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
  $domain = {}
  $realm = {}
  $adminpw = {}
  $dspw = {}
  $otp = {}
  $dns = false
  $mkhomedir = false
  $ntp = false
  $kstart = true
  $desc = ''
  $locality = ''
  $location = ''
  $sssdtools = true
  $sssdtoolspkg = 'sssd-tools'
  $sssd = true
  $svrpkg = 'ipa-server'
  $clntpkg = $::osfamily ? {
    Debian  => 'freeipa-client',
    default => 'ipa-client',
  }
  $ldaputils = true
  $ldaputilspkg = $::osfamily ? {
    Debian  => 'ldap-utils',
    default => 'openldap-clients',
  }
}
