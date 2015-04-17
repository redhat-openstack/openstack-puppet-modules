#
# Copyright (C) 2014 eNovance SAS <licensing@enovance.com>
#
# Author: Emilien Macchi <emilien.macchi@enovance.com>
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

# tuskar::init
#
# Tuskar base config
#
# == Parameters
#
# [*database_connection*]
#   (optional) Connection url to connect to tuskar database.
#   Defaults to 'sqlite:////var/lib/tuskar/tuskar.sqlite'
#
# [*database_idle_timeout*]
#   (optional) Timeout before idle db connections are reaped.
#   Defaults to 3600
#
class tuskar(
  $database_connection          = 'sqlite:////var/lib/tuskar/tuskar.sqlite',
  $database_idle_timeout        = 3600,
) {
  include ::tuskar::params

  exec { 'post-tuskar_config':
    command     => '/bin/echo "Tuskar config has changed"',
    refreshonly => true,
  }

}
