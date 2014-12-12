#
# Copyright (C) 2014 eNovance SAS <licensing@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# == Class: cloud::logging::agent
#
# Configure logging agent
#
# === Parameters:
#
# [*syslog_enable*]
#   (optional) Enable the configuration of rsyslog
#   Defaults to false
#
# [*sources*]
#   (optional) Fluentd sources
#   Defaults to empty hash
#
# [*matches*]
#   (optional) Fluentd matches
#   Defaults to empty hash
#
# [*plugins*]
#   (optional) Fluentd plugins to install
#   Defaults to empty hash
#
# [*logrotate_rule*]
#   (optional) A log rotate rule for the logging agent
#   Defaults to empty hash
#
class cloud::logging::agent(
  $syslog_enable  = false,
  $sources        = {},
  $matches        = {},
  $plugins        = {},
  $logrotate_rule = $cloud::params::logging_agent_logrotate_rule,
) inherits cloud::params {

  include cloud::logging

  if $syslog_enable {
    include rsyslog::client
  }

  file { '/var/db':
    ensure => directory,
  } ->
  file { '/var/db/td-agent':
    ensure  => 'directory',
    owner   => 'td-agent',
    group   => 'td-agent',
    require => Class['fluentd'],
  }

  ensure_resource('fluentd::configfile', keys($sources))
  ensure_resource('fluentd::configfile', keys($matches))
  create_resources('fluentd::source', $sources, {'require' => 'File[/var/db/td-agent]', 'notify' => 'Service[td-agent]'})
  create_resources('fluentd::match', $matches, {'notify'   => 'Service[td-agent]'})
  create_resources('fluentd::install_plugin', $plugins)
  create_resources('logrotate::rule', $logrotate_rule)

}
