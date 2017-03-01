# Author::    Liam Bennett  (mailto:lbennett@opentable.com)
# Copyright:: Copyright (c) 2013 OpenTable Inc
# License::   MIT

# == Class kafka::params
#
# This class is meant to be called from kafka::broker
# It sets variables according to platform
#
class kafka::params {
  $datastore  = '/var/kafka'
  $package_dir = '/var/lib/kafka'
  $mirror_url = 'http://mirrors.ukfast.co.uk/sites/ftp.apache.org'
  $version = '0.8.2.1'
  $scala_version = '2.10'
  $install_java = true
  $install_dir = "/opt/kafka-${scala_version}-${version}"

  $service_restart = true

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
    'controlled.shutdown.enable'                    => true,
    'controlled.shutdown.max.retries'               => '3',
    'controlled.shutdown.retry.backoff.ms'          => '5000',
    'auto.leader.rebalance.enable'                  => true,
    'leader.imbalance.per.broker.percentage'        => '10',
    'leader.imbalance.check.interval.seconds'       => '300',
    'offset.metadata.max.bytes'                     => '1024'
  }

  #http://kafka.apache.org/documentation.html#consumerconfigs
  $consumer_config_defaults = {
    'group.id'                        => '',
    'zookeeper.connect'               => '',
    'consumer.id'                     => '',
    'socket.timeout.ms'               => '30000',
    'socket.receive.buffer.bytes'     => '65536',
    'fetch.message.max.bytes'         => '1048576',
    'auto.commit.enable'              => true,
    'auto.commit.interval.ms'         => '10000',
    'queued.max.message.chunks'       => '10',
    'rebalance.max.retries'           => '4',
    'fetch.min.bytes'                 => '1',
    'fetch.wait.max.ms'               => '100',
    'rebalance.backoff.ms'            => '2000',
    'refresh.leader.backoff.ms'       => '200',
    'auto.offset.reset'               => 'largest',
    'consumer.timeout.ms'             => '-1',
    'client.id'                       => '',
    'zookeeper.session.timeout.ms'    => '6000',
    'zookeeper.connection.timeout.ms' => '6000',
    'zookeeper.sync.time.ms'          => '2000'
  }

  #http://kafka.apache.org/documentation.html#producerconfigs
  $producer_config_defaults = {
    'metadata.broker.list'               => '',
    'request.required.acks'              => '0',
    'request.timeout.ms'                 => '10000',
    'producer.type'                      => 'sync',
    'serializer.class'                   => 'kafka.serializer.DefaultEncoder',
    'key.serializer.class'               => '',
    'partitioner.class'                  => 'kafka.producer.DefaultPartitioner',
    'compression.codec'                  => 'none',
    'compressed.topics'                  => '',
    'message.send.max.retries'           => '3',
    'retry.backoff.ms'                   => '100',
    'topic.metadata.refresh.interval.ms' => '600000',
    'queue.buffering.max.ms'             => '5000',
    'queue.buffering.max.messages'       => '10000',
    'queue.enqueue.timeout.ms'           => '-1',
    'batch.num.messages'                 => '200',
    'send.buffer.bytes'                  => '102400',
    'client.id'                          => ''
  }

  #https://cwiki.apache.org/confluence/pages/viewpage.action?pageId=27846330
  #https://kafka.apache.org/documentation.html#basic_ops_mirror_maker
  $consumer_configs = ['/opt/kafka/config/consumer-1.properties']
  $producer_config = '/opt/kafka/config/producer.properties'
  $num_streams = 2
  $num_producers = 1
  $whitelist = '.*'
  $blacklist = ''

  $consumer_service_config = {
    'autocommit.interval.ms'    => '60000',
    'blacklist'                 => '',
    'consumer-timeout-ms'       => '-1',
    'csv-reporter-enabled'      => '',
    'fetch-size'                => '1048576',
    'formatter'                 => 'kafka.consumer.DefaultMessageFormatter',
    'from-beginning'            => '',
    'group'                     => 'console-consumer-53705',
    'max-messages'              => '',
    'max-wait-ms'               => '100',
    'metrics-dir'               => '',
    'min-fetch-bytes'           => '1',
    'property'                  => '',
    'refresh-leader-backoff-ms' => '200',
    'skip-message-on-error'     => '',
    'socket-buffer-size'        => '2097152',
    'socket-timeout-ms'         => '30000',
    'topic'                     => '',
    'whitelist'                 => '',
    'zookeeper'                 => ''
  }

  $producer_service_config = {
    'batch-size'               => '200',
    'broker-list'              => '',
    'compress'                 => '',
    'key-serializer'           => 'kafka.serializer.StringEncoder',
    'line-reader'              => 'kafka.producer.ConsoleProducer$LineMessageReader',
    'message-send-max-retries' => '3',
    'property'                 => '',
    'queue-enqueuetimeout-ms'  => '2147483647',
    'queue-size'               => '10000',
    'request-required-acks'    => '0',
    'request-timeout-ms'       => '1500',
    'retry-backoff-ms'         => '100',
    'socket-buffer-size'       => '102400',
    'sync'                     => '',
    'timeout'                  => '1000',
    'topic'                    => '',
    'value-serializer'         => 'kafka.serializer.StringEncoder'
  }

}
