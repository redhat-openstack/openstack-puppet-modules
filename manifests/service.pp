# == Class kafka::service
#
# This class is meant to be called from kafka
# It ensure the service is running
#
class kafka::service {

  #service { 'kafka':
  #  ensure   => running,
  #  provider => 'upstart',
  #  require  => File['kafka-init'],
  #}
}
