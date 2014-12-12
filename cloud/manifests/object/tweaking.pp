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
# Swift tweaking
#
class cloud::object::tweaking {
  file {'/etc/sysctl.d/swift-tuning.conf':
    content => "
# disable TIME_WAIT.. wait..
net.ipv4.tcp_tw_recycle=1
net.ipv4.tcp_tw_reuse=1

# disable syn cookies
net.ipv4.tcp_syncookies = 0

# double amount of allowed conntrack
net.ipv4.netfilter.ip_conntrack_max = 524288
net.ipv4.netfilter.ip_conntrack_tcp_timeout_time_wait = 2
net.ipv4.netfilter.ip_conntrack_tcp_timeout_close_wait = 2

net.ipv4.ip_local_port_range = 1024 65000

## 10Gb Tuning
net.core.netdev_max_backlog = 300000
net.ipv4.tcp_sack = 0

",
    owner   => 'root',
    group   => 'root',
  }

  exec{'update-etc-modules-with-ip_conntrack':
    command => '/bin/echo ip_conntrack >> /etc/modules',
    unless  => '/bin/grep -qFx "ip_conntrack" /etc/modules',
  }

  # Load sysctl and module only the first time
  exec{'load-ip_conntrack':
    command => '/sbin/modprobe ip_conntrack',
    unless  => '/bin/grep -qFx "ip_conntrack" /etc/modules',
    require => File['/etc/sysctl.d/swift-tuning.conf']
  }
  exec{'reload-sysctl-swift-tunning':
    command => '/sbin/sysctl -p /etc/sysctl.d/swift-tuning.conf',
    unless  => '/bin/grep -qFx "ip_conntrack" /etc/modules',
    require => File['/etc/sysctl.d/swift-tuning.conf']
  }

  file{'/var/log/swift':
    ensure => directory,
    owner  => swift,
    group  => swift,
  }

  file{'/etc/logrotate.d/swift':
    content => "
  /var/log/swift/proxy.log /var/log/swift/proxy.error.log /var/log/swift/account-server.log /var/log/swift/account-server.error.log /var/log/swift/container-server.log /var/log/swift/container-server.error.log /var/log/swift/object-server.log /var/log/swift/object-server.error.log
{
        rotate 7
        daily
        missingok
        notifempty
        delaycompress
        compress
        postrotate
        endscript
}
"
  }

}
