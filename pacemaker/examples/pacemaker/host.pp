class hosts (
  $hostname = 'node',
) {
  resources { 'host':
    purge => true,
  }

  host { 'localhost' :
    ip => '127.0.0.1',
    host_aliases => [$hostname],
  }
}

class hostname (
  $hostname = 'node',
) {

  if $::osfamily == 'Debian' {
    file { 'hostname' :
      ensure  => 'present',
      path    => '/etc/hostname',
      content => "${hostname}\n",
    }
  }

  exec { 'set-hostname' :
    command  => "hostname ${hostname}",
    unless   => "test `uname -n` = '${hostname}'",
    provider => 'shell',
  }

}

include ::hosts
include ::hostname