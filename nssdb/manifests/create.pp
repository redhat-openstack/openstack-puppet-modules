# Create an empty NSS database with a password file.
#
# Parameters:
#   $dbname           - required - the directory to store the db
#   $owner_id         - required - the file/directory user
#   $group_id         - required - the file/directory group
#   $password         - required - password to set on the database
#   $basedir          - optional - defaults to /etc/pki
#   $cacert           - optional - path to CA certificate in PEM format
#   $canickname       - default CA nickname
#   $catrust          - default CT,CT,
#
# Actions:
#   creates a new NSS database, consisting of 4 files:
#      cert8.db, key3.db, secmod.db and a password file, password.conf
#
# Requires:
#   $dbname must be set
#   $owner_id must be set
#   $group_id must be set
#   $password must be set
#
# Sample Usage:
#
# nssdb::create {'test':
#    owner_id => 'qpidd',
#    group_id => 'qpidd',
#    password => 'test'}
#
# This will create an NSS database in /etc/pki/test
#
define nssdb::create (
  $dbname = $title,
  $owner_id,
  $group_id,
  $password,
  $basedir = '/etc/pki',
  $cacert = '/etc/pki/certs/CA/ca.crt',
  $canickname = 'CA',
  $catrust = 'CT,CT,'
) {
  ensure_packages(['nss-tools'])

  file {"${basedir}/${dbname}":
    ensure  => directory,
    mode    => 0600,
    owner   => $owner_id,
    group   => $group_id,
  }
  file {"${basedir}/${dbname}/password.conf":
    ensure  => file,
    mode    => 0600,
    owner   => $owner_id,
    group   => $group_id,
    content => $password,
    require => [
        File["${basedir}/${dbname}"],
    ],
  }
  file { ["${basedir}/${dbname}/cert8.db", "${basedir}/${dbname}/key3.db", "${basedir}/${dbname}/secmod.db"] :
    ensure  => file,
    mode    => 0600,
    owner   => $owner_id,
    group   => $group_id,
    require => [
        File["${basedir}/${dbname}/password.conf"],
        Exec['create_nss_db'],
    ],
  }

  exec {'create_nss_db':
    command => "/usr/bin/certutil -N -d ${basedir}/${dbname} -f ${basedir}/${dbname}/password.conf",
    creates => ["${basedir}/${dbname}/cert8.db", "${basedir}/${dbname}/key3.db", "${basedir}/${dbname}/secmod.db"],
    require => [
        File["${basedir}/${dbname}"],
        File["${basedir}/${dbname}/password.conf"],
        Package['nss-tools'],
    ],
      notify => [
        Exec["add_ca_cert"],
      ],
  }

  exec {'add_ca_cert':
    command => "/usr/bin/certutil -A -n ${canickname} -d ${basedir}/${dbname} -t ${catrust} -a -i ${cacert}",
    require => [
        Package['nss-tools'],
    ],
    refreshonly => true,
    onlyif => "/usr/bin/test -e $cacert",
  }
}
