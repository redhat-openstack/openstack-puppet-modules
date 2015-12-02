# == Class uchiwa::config
#
# This class is called from uchiwa
#
class uchiwa::config inherits uchiwa {

  file { '/etc/sensu/uchiwa.json':
    ensure  => file,
    content => template('uchiwa/etc/sensu/uchiwa.json.erb'),
    owner   => uchiwa,
    group   => uchiwa,
    mode    => '0440',
  }
}
