# == Class uchiwa::config
#
# This class is called from uchiwa
#
class uchiwa::config {

  file { '/etc/sensu/uchiwa.json':
    owner    => 'root',
    group    => 'root',
    mode     => '0655',
    content  => template('uchiwa/etc/sensu/uchiwa.json.erb'),
  }

}
