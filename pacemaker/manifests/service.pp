# == Class: pacemaker::service
#
# Configure the pacemaker system service settings
#
# === Parameters:
#
# [*ensure*]
#   (optional) Make sure the service is running or stopped
#   Defaults to running
#
# [*hasstatus*]
#   (optional) Whether the service reports its status
#   Defaults to true
#
# [*hasrestart*]
#   (optional) Whether the service can be restarted
#   Defaults to true
#
# [*enable*]
#   (optional) Whether to enable the service on boot
#   Defaults to true
#
# === Dependencies
#
#  None
#
# === Authors
#
#  Crag Wolfe <cwolfe@redhat.com>
#  Jason Guiditta <jguiditt@redhat.com>
#
# === Copyright
#
# Copyright (C) 2016 Red Hat Inc.
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
class pacemaker::service (
  $ensure     = running,
  $hasstatus  = true,
  $hasrestart = true,
  $enable     = true,
) {
  include ::pacemaker::params

  if $::pacemaker::params::pcsd_mode {
    # only set up pcsd, not the other cluster services which have
    # very specific setup and when-to-start-up requirements
    # that are taken care of in corosync.pp
    service { 'pcsd':
      ensure     => $ensure,
      hasstatus  => $hasstatus,
      hasrestart => $hasrestart,
      enable     => $enable,
      require    => Class['::pacemaker::install'],
    }

    # The idempotent version of pcs cluster enable, which whas enable
    # unconditionally.
    service { ['corosync', $::pacemaker::params::service_name]:
      enable  => true,
      require => Class['::pacemaker::install'],
      tag     => 'pcsd-cluster-service',
    }
  } else {
    service { $::pacemaker::params::service_name:
      ensure     => $ensure,
      hasstatus  => $hasstatus,
      hasrestart => $hasrestart,
      enable     => $enable,
      require    => Class['::pacemaker::install'],
    }
  }
}
