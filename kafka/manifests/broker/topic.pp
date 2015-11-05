# Author::    Liam Bennett  (mailto:lbennett@opentable.com)
# Copyright:: Copyright (c) 2013 OpenTable Inc
# License::   MIT

# == Define: kafka::broker::topic
#
# This private class is meant to be called from `kafka::broker`.
# It manages the creation of topics on the kafka broker
#
define kafka::broker::topic(
  $ensure = '',
  $zookeeper = '',
  $replication_factor = 1,
  $partitions = 1
) {

  if $ensure == 'present' {
    exec { "create topic ${name}":
      command => "/opt/kafka/bin/kafka-topics.sh --create --zookeeper '${zookeeper}' --replication-factor ${replication_factor} --partitions ${partitions} --topic ${name}",
      unless  => "/bin/bash -c \"if [[ \\\"`/opt/kafka/bin/kafka-topics.sh --list --zookeeper '${zookeeper}' ${name}`\\\" == *${name}* ]]; then exit 0; else exit 1; fi\""
    }
  }
}
