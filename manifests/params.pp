# == Class kafka::params
#
# This class is meant to be called from kafka
# It sets variables according to platform
#
class kafka::params {
  $datastore   = '/var/kafka'
  $package_dir = '/var/lib/kafka'
  $mirror_url = 'http://mirrors.ukfast.co.uk/sites/ftp.apache.org'
  $version = '0.8.1.1'
  $scala_version = '2.8.0'

  #http://kafka.apache.org/documentation.html#configuration
  $broker_id = '0'
  $port = '9092'
  $host_name = $::fqdn
  $advertised_host_name = $::fqdn
  $advertised_port = '9092'
  $num_network_threads = '2'
  $num_io_threads = '8'
  $socket_send_buffer_bytes = '1048576'
  $socket_receive_buffer_bytes = '1048576'
  $socket_request_max_bytes = '104857600'
  $log_dirs = '/tmp/kafka-logs'
  $num_partitions = '2'
  $log_flush_interval_messages = '10000'
  $log_flush_interval_ms = '1000'
  $log_retention_hours = '168'
  $log_retention_bytes = '1073741824'
  $log_segment_bytes = '536870912'
  $log_retention_check_interval_ms = '60000'
  $log_cleaner_enable = false
  $zookeeper_connect = 'localhost:2181'
  $zookeeper_connect_timeout_ms = '1000000'

}
