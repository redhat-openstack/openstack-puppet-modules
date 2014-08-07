# == Class uchiwa::config
#
# This class is called from uchiwa
#
class uchiwa::config {

  datacat { '/etc/sensu/uchiwa.json':
    template => 'uchiwa/etc/sensu/uchiwa.json.erb',
  }
}
