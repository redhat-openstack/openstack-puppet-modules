# Request a new certificate from IPA using certmonger
#
# Parameters:
#   $dbname           - required for nss, unused for openssl. The directory 
#                       to store the db
#   $seclib,          - required - select nss or openssl
#   $principal        - required - the IPA principal to associate the
#                                  certificate with
#   $nickname         - required for nss, unused for openssl. The NSS
#                       certificate nickname
#   $cert             - required for openssl, unused for nss. The full file
#                       path to store the certificate in.
#   $key              - required for openssl, unused for nss. The full file
#                       path to store the key in
#   $basedir          - The base directory for $dbname, defaults
#                       to '/etc/pki'. Not used with openssl.
#   $owner_id         - owner of OpenSSL cert and key files
#   $group_id         - group of OpenSSL cert and key files
#   $hostname         - hostname in the subject of the certificate.
#                       defaults to current fqdn.
#
# Actions:
#   Submits a certificate request to an IPA server for a new certificate.
#
# Requires:
#   The NSS db must already exist. It can be created using the nssdb
#   module.
#
# Sample Usage:
#
# NSS:
#  certmonger::request_ipa_cert {'test':
#    seclib => "nss",
#    nickname => "broker",
#    principal => "qpid/${fqdn}"}
#
# OpenSSL:
#  certmonger::request_ipa_cert {'test':
#     seclib => "openssl",
#     principal => "qpid/${fqdn}",
#     key => "/etc/pki/test2/test2.key",
#     cert => "/etc/pki/test2/test2.crt",
#     owner_id => 'qpidd',
#     group_id => 'qpidd'}

define certmonger::request_ipa_cert (
  $dbname = $title,
  $seclib,
  $principal,
  $nickname = undef,
  $cert = undef,
  $key = undef,
  $basedir = '/etc/pki',
  $owner_id = undef,
  $group_id = undef,
  $hostname = undef
) {
  include certmonger::server

  $principal_no_slash = regsubst($principal, '\/', '_')

  # Only execute certmonger if IPA client is configured
  $onlyif = "/usr/bin/test -s /etc/ipa/default.conf"

  if $hostname == undef {
      $subject = ''
  } else {
      $subject = "-N cn=${hostname}"
  }

  if $seclib == 'nss' {
      $options = "-d ${basedir}/${dbname} -n ${nickname} -p ${basedir}/${dbname}/password.conf"
      $unless = "/usr/bin/getcert list -d ${basedir}/${dbname} -n ${nickname}"

      exec {"get_cert_nss_${title}":
        command => "/usr/bin/ipa-getcert request ${options} -K ${principal} ${subject}",
        onlyif  => "${onlyif}",
        unless  => "${unless}",
        require => [
            Service['certmonger'],
            File["${basedir}/${dbname}/password.conf"],
        ],
      }
  }
  elsif $seclib == 'openssl' {

      $options = "-k ${key} -f ${cert}"
      $unless = "/usr/bin/getcert list -f ${cert}"

      exec {"get_cert_openssl_${title}":
        command => "/usr/bin/ipa-getcert request ${options} -K ${principal} ${subject}",
        onlyif  => "${onlyif}",
        unless  => "${unless}",
        require => [
            Service['certmonger'],
        ],
        notify => Exec["wait_for_certmonger_${title}"],
      }

      # We need certmonger to finish creating the key before we
      # can proceed. Use onlyif as a way to execute multiple
      # commands without restorting to shipping a shell script.
      # This will call getcert to check the status of our cert
      # 5 times. This doesn't short circuit though, so all 5 will
      # always run, causing a 5-second delay.
      exec {"wait_for_certmonger_${title}":
        command => "true",
        onlyif => [
          "sleep 1 && getcert list -f ${cert}",
          "sleep 1 && getcert list -f ${cert}",
          "sleep 1 && getcert list -f ${cert}",
          "sleep 1 && getcert list -f ${cert}",
          "sleep 1 && getcert list -f ${cert}",
        ],
        path => "/usr/bin:/bin",
        refreshonly => true,
      }
  } else {
    fail("Unrecognized security library: ${seclib}")
  }
}
