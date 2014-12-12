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
# == Class: cloud::params
#
# Configure set of default parameters
#
class cloud::params {

  # cloud::logging::agent
  $logging_agent_logrotate_rule = {
    'td-agent' => {
      'path'          => '/var/log/td-agent/td-agent.log',
      'rotate'        => 30,
      'compress'      => true,
      'delaycompress' => true,
      'ifempty'       => false,
      'create'        => true,
      'create_mode'   => '640',
      'create_owner'  => 'td-agent',
      'create_group'  => 'td-agent',
      'sharedscripts' => true,
      'postrotate'    => ['pid=/var/run/td-agent/td-agent.pid', 'test -s $pid && kill -USR1 "$(cat $pid)"'],
    }
  }

  $puppetmaster_service_name = 'puppetmaster'

  case $::osfamily {
    'RedHat': {
      # Specific to Red Hat
      $start_haproxy_service      = '"/usr/bin/systemctl start haproxy"'
      $stop_haproxy_service       = '"/usr/bin/systemctl stop haproxy"'
      $horizon_auth_url           = 'dashboard'
      $libvirt_service_name       = 'libvirtd'
      $keepalived_name_is_process = false
      $keepalived_vrrp_script     = 'systemctl status haproxy.service'
      $puppetmaster_package_name  = 'puppet-server'
    } # RedHat
    'Debian': {
      # Specific to Debian / Ubuntu
      $start_haproxy_service      = '"/etc/init.d/haproxy start"'
      $stop_haproxy_service       = '"/etc/init.d/haproxy stop"'
      $horizon_auth_url           = 'horizon'
      $keepalived_name_is_process = true
      $keepalived_vrrp_script     = undef
      $puppetmaster_package_name  = 'puppetmaster'
      case $::operatingsystem {
        'Ubuntu': {
          $libvirt_service_name = 'libvirt-bin'
        }
        default: {
          $libvirt_service_name = 'libvirtd'
        }
      }
    } # Debian
    default: {
      fail("Unsupported osfamily (${::osfamily})")
    }
  }

}
