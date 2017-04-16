#
# class for installing qpid server for manila
#
#
class manila::qpid(
  $enabled = true,
  $user='guest',
  $password='guest',
  $file='/var/lib/qpidd/qpidd.sasldb',
  $realm='OPENSTACK'
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

  class { 'qpid::server':
    service_ensure => $service_ensure
  }

}
