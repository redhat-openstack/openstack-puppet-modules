# Class: ipa::master_extca
#
# Defines associated files of an IPA server with an external CA
class ipa::master_extca (
  $host          = $name,
  $realm         = {},
  $domain        = {},
  $adminpw       = {},
  $dspw          = {},
  $dnsopt        = {},
  $ntpopt        = {},
  $extcertpath   = {},
  $extcert       = {},
  $extcacertpath = {},
  $extcacert     = {},
  $dirsrv_pkcs12 = {},
  $http_pkcs12   = {},
  $dirsrv_pin    = {},
  $http_pin      = {},
  $subject       = {},
  $selfsign      = {}
) {

  if is_string($extcertpath) and is_string($extcacertpath) {
    file { $extcertpath:
      ensure  => 'file',
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      content => $extcert
    }

    file { $extcacertpath:
      ensure  => 'file',
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      content => $extcacert
    }

    if is_string($dirsrv_pkcs12) and is_string($dirsrv_pin) {
      $dirsrv_pkcs12opt = "--dirsrv_pkcs12=${dirsrv_pkcs12}"
      $dirsrv_pinopt = "--dirsrv_pin=${dirsrv_pin}"
      file { $dirsrv_pkcs12:
        ensure => 'file',
        owner  => 'root',
        group  => 'root',
        mode   => '0600',
        source => "puppet:///files/ipa/${dirsrv_pkcs12}"
      }
    } else {
      $dirsrv_pkcs12opt = ''
      $dirsrv_pinopt = ''
    }

    if is_string($http_pkcs12) {
      $http_pkcs12opt = "--http_pkcs12=${http_pkcs12}"
      $http_pinopt = "--http_pin=${http_pin}"
      file { $http_pkcs12:
        ensure => 'file',
        owner  => 'root',
        group  => 'root',
        mode   => '0600',
        source => "puppet:///files/ipa/${http_pkcs12}"
      }
    } else {
      $http_pkcs12opt = ''
      $http_pinopt = ''
    }

    if is_string($subject) {
      $subjectopt = "--subject=${subject}"
    } else {
      $subjectopt = ''
    }

    $selfsignopt = $selfsign ? {
      true    => '--selfsign',
      default => ''
    }

    if defined($extcertpath) and defined($extcacertpath) {
      if validate_absolute_path($extcertpath) and validate_absolute_path($extcacertpath) {
        ipa::serverinstall_extca { $::fqdn:
          adminpw          => $ipa::master_extca::adminpw,
          dspw             => $ipa::master_extca::dspw,
          extcertpath      => $ipa::master_extca::extcertpath,
          extcacertpath    => $ipa::master_extca::extcacertpath,
          dirsrv_pkcs12opt => $ipa::master_extca::dirsrv_pkcs12opt,
          http_pkcs12opt   => $ipa::master_extca::http_pkcs12opt,
          dirsrv_pinopt    => $ipa::master_extca::dirsrv_pinopt,
          http_pinopt      => $ipa::master_extca::http_pinopt,
          subjectopt       => $ipa::master_extca::subjectopt,
          selfsignopt      => $ipa::master_extca::selfsignopt
        }

        class { 'ipa::service':
          require => Ipa::Serverinstall_extca[$::fqdn]
        }
      }
    }
  }
}
