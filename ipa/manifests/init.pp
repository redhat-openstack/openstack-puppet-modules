# == Class: ipa
#
# Manages IPA masters, replicas and clients.
#
# === Parameters
#
#  $master = false - Configures a server to be an IPA master LDAP/Kerberos node.
#  $replica = false - Configures a server to be an IPA replica LDAP/Kerberos node.
#  $client = false - Configures a server to be an IPA client.
#  $cleanup = false - Removes IPA specific packages.
#  $domain = undef - Defines the LDAP domain.
#  $realm = undef - Defines the Kerberos realm.
#  $adminpw = undef - Defines the IPA administrative user password.
#  $dspw = undef - Defines the IPA directory services password.
#  $otp = undef - Defines an IPA client one-time-password.
#  $dns = false - Controls the option to configure a DNS zone with the IPA master setup.
#  $fixedprimary = false - Configure sssd to use a fixed server as the primary IPA server.
#  $forwarders = [] - Defines an array of DNS forwarders to use when DNS is setup. An empty list will use the Root Nameservers.
#  $extca = false - Controls the option to configure an external CA.
#  $extcertpath = undef - Defines a file path to the external certificate file. Somewhere under /root is recommended.
#  $extcert = undef - The X.509 certificate in base64 encoded format.
#  $extcacertpath = undef - Defines a file path to the external CA certificate file. Somewhere under /root is recommended.
#  $extcacert = undef - The X.509 CA certificate in base64 encoded format.
#  $dirsrv_pkcs12 = undef - PKCS#12 file containing the Directory Server SSL Certificate, also corresponds to the Puppet fileserver path under fileserverconfig for $confdir/files/ipa
#  $http_pkcs12 = undef - The PKCS#12 file containing the Apache Server SSL Certificate, also corresponds to the Puppet fileserver path under fileserverconfig for $confdir/files/ipa
#  $dirsrv_pin = undef - The password of the Directory Server PKCS#12 file.
#  $http_pin = undef - The password of the Apache Server PKCS#12 file.
#  $subject = undef - The certificate subject base.
#  $selfsign = false - Configure a self-signed CA instance for issuing server certificates instead of using dogtag for certificates.
#  $loadbalance = false - Controls the option to include any additional hostnames to be used in a load balanced IPA client configuration.
#  $ipaservers = [] - Defines an array of additional hostnames to be used in a load balanced IPA client configuration.
#  $mkhomedir = false - Controls the option to create user home directories on first login.
#  $ntp = false - Controls the option to configure NTP on a client.
#  $kstart = true - Controls the installation of kstart.
#  $desc = '' - Controls the description entry of an IPA client.
#  $locality = '' - Controls the locality entry of an IPA client.
#  $location = '' - Controls the location entry of an IPA client.
#  $sssdtools = true - Controls the installation of the SSSD tools package.
#  $sssdtoolspkg = 'sssd-tools' - SSSD tools package.
#  $sssd = true - Controls the option to start the SSSD service.
#  $sudo = false - Controls the option to configure sudo in LDAP.
#  $sudopw = undef - Defines the sudo user bind password.
#  $debiansudopkg = true - Controls the installation of the Debian sudo-ldap package.
#  $automount = false - Controls the option to configure automounter maps in LDAP.
#  $autofs = false - Controls the option to start the autofs service and install the autofs package.
#  $svrpkg = 'ipa-server' - IPA server package.
#  $clntpkg = 'ipa-client' - IPA client package.
#  $ldaputils = true - Controls the instalation of the LDAP utilities package.
#  $ldaputilspkg = 'openldap-clients' - LDAP utilities package.
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
  $master        = false,
  $replica       = false,
  $client        = false,
  $cleanup       = false,
  $domain        = undef,
  $realm         = undef,
  $adminpw       = undef,
  $dspw          = undef,
  $otp           = undef,
  $dns           = false,
  $fixedprimary  = false,
  $forwarders    = [],
  $extca         = false,
  $extcertpath   = undef,
  $extcert       = undef,
  $extcacertpath = undef,
  $extcacert     = undef,
  $dirsrv_pkcs12 = undef,
  $http_pkcs12   = undef,
  $dirsrv_pin    = undef,
  $http_pin      = undef,
  $subject       = undef,
  $selfsign      = false,
  $loadbalance   = false,
  $ipaservers    = [],
  $mkhomedir     = false,
  $ntp           = false,
  $kstart        = true,
  $desc          = '',
  $locality      = '',
  $location      = '',
  $sssdtools     = true,
  $sssdtoolspkg  = 'sssd-tools',
  $sssd          = true,
  $sudo          = false,
  $sudopw        = undef,
  $debiansudopkg = true,
  $automount     = false,
  $autofs        = false,
  $svrpkg        = 'ipa-server',
  $clntpkg       = $::osfamily ? {
    Debian  => 'freeipa-client',
    default => 'ipa-client',
  },
  $ldaputils     = true,
  $ldaputilspkg  = $::osfamily ? {
    Debian  => 'ldap-utils',
    default => 'openldap-clients',
  },
  $idstart       = false
) {

  @package { $ipa::svrpkg:
    ensure => installed
  }

  @package { $ipa::clntpkg:
    ensure => installed
  }

  if $ipa::ldaputils {
    @package { $ipa::ldaputilspkg:
      ensure => installed
    }
  }

  if $ipa::sssdtools {
    @package { $ipa::sssdtoolspkg:
      ensure => installed
    }
  }

  if $ipa::kstart {
    @package { 'kstart':
      ensure => installed
    }
  }

  @service { 'ipa':
    ensure  => 'running',
    enable  => true,
    require => Package[$ipa::svrpkg]
  }

  if $ipa::sssd {
    @package { 'sssd-common':
      ensure => installed
    }

    @service { 'sssd':
      ensure  => 'running',
      enable  => true,
      require => Package['sssd-common']
    }
  }

  if $ipa::dns {
    @package { 'bind-dyndb-ldap':
      ensure => installed
    }
  }

  if $ipa::mkhomedir and $::osfamily == 'RedHat' and $::lsbmajdistrelease == '6' {
    service { 'oddjobd':
      ensure => 'running',
      enable => true
    }
  }

  if $ipa::autofs {
    @package { 'autofs':
      ensure => installed
    }

    @service { 'autofs':
      ensure => 'running',
      enable => true
    }
  }

  @cron { 'k5start_root':
    command => '/usr/bin/k5start -f /etc/krb5.keytab -U -o root -k /tmp/krb5cc_0 > /dev/null 2>&1',
    user    => 'root',
    minute  => '*/1',
    require => Package['kstart']
  }

  if $ipa::master and $ipa::replica {
    fail('Conflicting options selected. Cannot configure both master and replica at once.')
  }

  if ! $ipa::cleanup {
    if $ipa::master or $ipa::replica {
      validate_re($ipa::adminpw,'^.........*$','Parameter "adminpw" must be at least 8 characters long')
      validate_re($ipa::dspw,'^.........*$','Parameter "dspw" must be at least 8 characters long')
    }
    if $ipa::master and $ipa::idstart {
      validate_re($ipa::idstart,'^......*$', 'Parameter "idstart" must be an integer greater than 10000 ')
      validate_re($ipa::idstart,'^\d+$', 'Parameter "idstart" must be an integer ')
    }

    if ! $ipa::domain {
      fail('Required parameter "domain" missing')
    }

    if ! $ipa::realm {
      fail('Required parameter "realm" missing')
    }

    if ! is_domain_name($ipa::domain) {
      fail('Parameter "domain" is not a valid domain name')
    }

    if ! is_domain_name($ipa::realm) {
      fail('Parameter "realm" is not a valid domain name')
    }
  }

  if $ipa::cleanup {
    if $ipa::master or $ipa::replica or $ipa::client {
      fail('Conflicting options selected. Cannot cleanup during an installation.')
    } else {
      ipa::cleanup { $::fqdn:
        svrpkg  => $ipa::svrpkg,
        clntpkg => $ipa::clntpkg
      }
    }
  }

  if $ipa::master {
    class { 'ipa::master':
      svrpkg        => $ipa::svrpkg,
      dns           => $ipa::dns,
      forwarders    => $ipa::forwarders,
      domain        => downcase($ipa::domain),
      realm         => upcase($ipa::realm),
      adminpw       => $ipa::adminpw,
      dspw          => $ipa::dspw,
      loadbalance   => $ipa::loadbalance,
      ipaservers    => $ipa::ipaservers,
      sudo          => $ipa::sudo,
      sudopw        => $ipa::sudopw,
      automount     => $ipa::automount,
      autofs        => $ipa::autofs,
      kstart        => $ipa::kstart,
      sssd          => $ipa::sssd,
      ntp           => $ipa::ntp,
      extca         => $ipa::extca,
      extcertpath   => $ipa::extcertpath,
      extcert       => $ipa::extcert,
      extcacertpath => $ipa::extcacertpath,
      extcacert     => $ipa::extcacert,
      dirsrv_pkcs12 => $ipa::dirsrv_pkcs12,
      http_pkcs12   => $ipa::http_pkcs12,
      dirsrv_pin    => $ipa::dirsrv_pin,
      http_pin      => $ipa::http_pin,
      subject       => $ipa::subject,
      selfsign      => $ipa::selfsign,
      idstart       => $ipa::idstart
    }

    if ! $ipa::adminpw {
      fail('Required parameter "adminpw" missing')
    }

    if ! $ipa::dspw {
      fail('Required parameter "dspw" missing')
    }
  }

  if $ipa::replica {
    class { 'ipa::replica':
      svrpkg      => $ipa::svrpkg,
      domain      => downcase($ipa::domain),
      adminpw     => $ipa::adminpw,
      dspw        => $ipa::dspw,
      kstart      => $ipa::kstart,
      sssd        => $ipa::sssd
    }

    class { 'ipa::client':
      clntpkg      => $ipa::clntpkg,
      ldaputils    => $ipa::ldaputils,
      ldaputilspkg => $ipa::ldaputilspkg,
      sssdtools    => $ipa::sssdtools,
      sssdtoolspkg => $ipa::sssdtoolspkg,
      sssd         => $ipa::sssd,
      kstart       => $ipa::kstart,
      loadbalance  => $ipa::loadbalance,
      ipaservers   => $ipa::ipaservers,
      mkhomedir    => $ipa::mkhomedir,
      domain       => downcase($ipa::domain),
      realm        => upcase($ipa::realm),
      otp          => $ipa::otp,
      sudo         => $ipa::sudo,
      automount    => $ipa::automount,
      autofs       => $ipa::autofs,
      ntp          => $ipa::ntp,
      fixedprimary => $ipa::fixedprimary,
      desc         => $ipa::desc,
      locality     => $ipa::locality,
      location     => $ipa::location
    }

    if ! $ipa::adminpw {
      fail('Required parameter "adminpw" missing')
    }

    if ! $ipa::dspw {
      fail('Required parameter "dspw" missing')
    }

    if ! $ipa::otp {
      fail('Required parameter "otp" missing')
    }
  }

  if $ipa::client {
    class { 'ipa::client':
      clntpkg       => $ipa::clntpkg,
      ldaputils     => $ipa::ldaputils,
      ldaputilspkg  => $ipa::ldaputilspkg,
      sssdtools     => $ipa::sssdtools,
      sssdtoolspkg  => $ipa::sssdtoolspkg,
      sssd          => $ipa::sssd,
      domain        => downcase($ipa::domain),
      realm         => upcase($ipa::realm),
      otp           => $ipa::otp,
      sudo          => $ipa::sudo,
      debiansudopkg => $ipa::debiansudopkg,
      automount     => $ipa::automount,
      autofs        => $ipa::autofs,
      mkhomedir     => $ipa::mkhomedir,
      loadbalance   => $ipa::loadbalance,
      ipaservers    => $ipa::ipaservers,
      ntp           => $ipa::ntp,
      fixedprimary  => $ipa::fixedprimary,
      desc          => $ipa::desc,
      locality      => $ipa::locality,
      location      => $ipa::location
    }

    if ! $ipa::otp {
      fail('Required parameter "otp" missing')
    }
  }
}
