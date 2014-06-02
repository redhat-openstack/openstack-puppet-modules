# => Class kafka::params
#
# This class is meant to be called from kafka::broker
# It sets variables according to platform
#
class kafka::params {
  $datastore  = '/var/kafka'
  $package_dir = '/var/lib/kafka'
  $mirror_url = 'http://mirrors.ukfast.co.uk/sites/ftp.apache.org'
  $version = '0.8.1.1'
  $scala_version = '2.8.0'
  $install_java = true
  $install_dir = "/usr/local/kafka-${scala_version}-${version}"

  #http://kafka.apache.org/documentation.html#brokerconfigs
  $broker_config_defaults = {
    'broker.id'                                     => '0',
    'log.dirs'                                      => '/tmp/kafka-logs',
    'port'                                          => '6667',
    'zookeeper.connect'                             => '',
    'message.max.bytes'                             => '1000000',
    'num.network.threads'                           => '3',
    'num.io.threads'                                => '8',
    'background.threads'                            => '4',
    'queued.max.requests'                           => '500',
    'host.name'                                     => '',
    'advertised.host.name'                          => '',
    'advertised.port'                               => '',
    'socket.send.buffer.bytes'                      => '102400',
    'socket.receive.buffer.bytes'                   => '102400',
    'socket.request.max.bytes'                      => '104857600',
    'num.partitions'                                => '1',
    'log.segment.bytes'                             => '1073741824',
    'log.roll.hours'                                => '168',
    'log.cleanup.policy'                            => 'delete',
    'log.retention.hours'                           => '168',
    'log.retention.minutes'                         => '10080',
    'log.retention.bytes'                           => '-1',
    'log.retention.check.interval.ms'               => '300000',
    'log.cleaner.enable'                            => false,
    'log.cleaner.threads'                           => '1',
    'log.cleaner.io.max.bytes.per.second'           => '',
    'log.cleaner.dedupe.buffer.size'                => '524288000',
    'log.cleaner.io.buffer.size'                    => '524288',
    'log.cleaner.io.buffer.load.factor'             => '0.9',
    'log.cleaner.backoff.ms'                        => '15000',
    'log.cleaner.min.cleanable.ratio'               => '0.5',
    'log.cleaner.delete.retention.ms'               => '86400000',
    'log.index.size.max.bytes'                      => '10485760',
    'log.index.interval.bytes'                      => '4096',
    'log.flush.interval.messages'                   => '',
    'log.flush.scheduler.interval.ms'               => '3000',
    'log.flush.interval.ms'                         => '',
    'log.delete.delay.ms'                           => '60000',
    'log.flush.offset.checkpoint.interval.ms'       => '60000',
    'auto.create.topics.enable'                     => true,
    'controller.socket.timeout.ms'                  => '30000',
    'controller.message.queue.size'                 => '10',
    'default.replication.factor'                    => '1',
    'replica.lag.time.max.ms'                       => '10000',
    'replica.lag.max.messages'                      => '4000',
    'replica.socket.timeout.ms'                     => '301000',
    'replica.socket.receive.buffer.bytes'           => '641024',
    'replica.fetch.max.bytes'                       => '10241024',
    'replica.fetch.wait.max.ms'                     => '500',
    'replica.fetch.min.bytes'                       => '1',
    'num.replica.fetchers'                          => '1',
    'replica.high.watermark.checkpoint.interval.ms' => '5000',
    'fetch.purgatory.purge.interval.requests'       => '10000',
    'producer.purgatory.purge.interval.requests'    => '10000',
    'zookeeper.session.timeout.ms'                  => '6000',
    'zookeeper.connection.timeout.ms'               => '6000',
    'zookeeper.sync.time.ms'                        => '2000',
    'controlled.shutdown.enable'                    => false,
    'controlled.shutdown.max.retries'               => '3',
    'controlled.shutdown.retry.backoff.ms'          => '5000',
    'auto.leader.rebalance.enable'                  => false,
    'leader.imbalance.per.broker.percentage'        => '10',
    'leader.imbalance.check.interval.seconds'       => '300',
    'offset.metadata.max.bytes'                     => '1024'
  }
}
