# == Class uchiwa::config
#
# This class is called from uchiwa
#
class uchiwa::config {

  file { '/etc/sensu/uchiwa.json':
    content => template('uchiwa/etc/sensu/uchiwa.json.erb'),
  }
}
