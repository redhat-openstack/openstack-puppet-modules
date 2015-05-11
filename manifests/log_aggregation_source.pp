# Copyright 2015 Red Hat, Inc.
# All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# == Define: tripleo::log_aggregation_source
#
# Capture logs from an OpenStack service using Fluentd
#
# === Parameters:
#
# [*path*]
#  (String) the path to the log file to tail
#
# [*multiline*]
#  (bool) whether or not to capture multiline log output as a single line
#  Defaults to true
#

define tripleo::log_aggregation_source ( $path, $multiline = true ) {
  $log_format = '/(?<time>[^ ]* [^ ]*) (?<pid>[^ ]*) (?<loglevel>[^ ]*) (?<class>[^ ]*) \[(?<context>.*)\] (?<message>.*)/'
  $log_format_firstline = '/(?<time>[^ ]* [^ ]*) (?<pid>[^ ]*) (?<loglevel>[^ ]*) (?<class>[^ ]*) \[(?<context>.*)\] (?<message>.*)/'
  $time_format = '%F %T.%L'

  if $multiline {
    # NB(sross): puppet-fluentd can't represent multiple keys with the
    # same name, so we have "format" and " format"
    # (i.e. the space is important)
    fluentd::source { "input-${name}":
      config => {
        '@type'            => 'tail',
        'path'             => $path,
        'tag'              => $name,
        ' format'          => 'multiline',
        'format_firstline' => $log_format_firstline,
        'format'           => $log_format,
        'time_format'      => $time_format
      },
      notify => Class['fluentd::service']
    }
  } else {
    fluentd::source { "input-${name}":
      config => {
        '@type'       => 'tail',
        'path'        => $path,
        'tag'         => $name,
        'format'      => $log_format,
        'time_format' => $time_format
      },
      notify => Class['fluentd::service']
    }
  }

  # puppet-fluentd doesn't have a good way to represent nested
  # structures (for the '<pair>' # element).
  fluentd::match { "add-metadata-to-${name}":
    pattern => $name,
    config  => {
      '@type'  => 'add',
      '<pair>' => "\n  service ${name}\n  hostname \"#{Socket.gethostname}\"\n</pair>"
    },
    notify  => Class['fluentd::service']
  }
}
