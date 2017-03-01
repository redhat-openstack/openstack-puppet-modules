# == Class: manila::qpid
#
# Class for installing qpid server for manila
#
# === Parameters
#
# [*enabled*]
#   (Optional) Whether to enable the service
#   Defaults to true.
#
# [*user*]
#   (Optional) The user to create in qpid
#   Defaults to 'guest'.
#
# [*password*]
#   (Optional) The password to create for the user
#   Defaults to 'guest'.
#
# [*file*]
#   (Optional) Sasl file for the user
#   Defaults to '/var/lib/qpidd/qpidd.sasldb'.
#
# [*realm*]
#   (Optional) Realm for the user
#   Defaults to 'OPENSTACK'.
#
#
class manila::qpid (
  $enabled  = true,
  $user     = 'guest',
  $password = 'guest',
  $file     = '/var/lib/qpidd/qpidd.sasldb',
  $realm    = 'OPENSTACK'
) {

  # only configure manila after the queue is up
  Class['qpid::server'] -> Package<| title == 'manila' |>

  if ($enabled) {
    $service_ensure = 'running'

    qpid_user { $user:
      password => $password,
      file     => $file,
      realm    => $realm,
      provider => 'saslpasswd2',
      require  => Class['qpid::server'],
    }

  } else {
    $service_ensure = 'stopped'
  }

  class { '::qpid::server':
    service_ensure => $service_ensure,
  }
}
