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
# [*checks*]
#   (optionnal) Hash of checks and their respective options
#   Defaults to {}.
#   Example :
#     $checks = {
#       'ntp' => {
#          'command' => '/etc/sensu/plugins/check-ntp.sh'},
#       'http' => {
#          'command' => '/etc/sensu/plugins/check-http.sh'},
#     }
#
# [*handlers*]
#   (optionnal) Hash of handlers and their respective options
#   Defaults to {}.
#   Example :
#     $handlers = {
#       'mail' => {
#          'command' => 'mail -s "Sensu Alert" contact@example.com'},
#     }
#
# [*plugins*]
#   (optionnal) Hash of handlers and their respective options
#   Defaults to {}.
#   Example :
#     $plugins = {
#       'http://www.example.com/ntp.sh' => {
#          'type'         => 'url',
#          'install_path' => '/etc/sensu/plugins',
#       }
#     }
#
# [*rabbitmq_user*]
#   (optionnal) Rabbitmq user
#   Defaults to 'sensu'
#
# [*rabbitmq_password*]
#   (optionnal) Rabbitmq_password
#   Defaults to 'rabbitpassword'
#
# [*rabbitmq_vhost*]
#   (optionnal) Rabbitmq vhost
#   Defaults to '/sensu'
#
# [*uchiwa_ip*]
#   (optionnal) IP address to bind uchiwa to
#   Defaults to '%{::ipaddress}'
class cloud::monitoring::server::sensu (
  $checks                    = {},
  $handlers                  = {},
  $plugins                   = {},
  $rabbitmq_user             = 'sensu',
  $rabbitmq_password         = 'rabbitpassword',
  $rabbitmq_vhost            = '/sensu',
  $uchiwa_ip                 = $::ipaddress,
) {

  @@rabbitmq_user { $rabbitmq_user :
    password => $rabbitmq_password,
  }
  @@rabbitmq_vhost { $rabbitmq_vhost :
    ensure  => present,
  }
  @@rabbitmq_user_permissions { "${rabbitmq_user}@${rabbitmq_vhost}" :
    configure_permission => '.*',
    read_permission      => '.*',
    write_permission     => '.*',
  }

  $rabbitmq_user_realized = query_nodes("Rabbitmq_user['${rabbitmq_user}']")

  if size($rabbitmq_user_realized) >= 1 {

    Service['redis-6379'] -> Service['sensu-api'] -> Service['sensu-server'] -> Service['uchiwa']
    Service['sensu-server'] -> Sensu::Plugin <<| |>>


    include cloud::monitoring::agent::sensu
    include redis

    create_resources('sensu::check', $checks)
    create_resources('sensu::handler', $handlers)
    create_resources('@@sensu::plugin', $plugins)

    include ::uchiwa
    uchiwa::api { 'OpenStack' :
      host => $uchiwa_ip,
    }
  }

}
