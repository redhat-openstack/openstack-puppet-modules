#
# Copyright (C) 2015 eNovance SAS <licensing@enovance.com>
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
#
# tuskar::ui
#
# Install UI (and UI extras)
#
# === Parameters:
#
# [*package_ensure*]
#   (optional) The state of the package
#   Defaults to present
#
# [*extras*]
#   (optional) Also install UI extras
#   Defaults to false
#
class tuskar::ui (
  $package_ensure = 'present',
  $extras         = false,
) {

  include ::tuskar::params

  package { 'tuskar-ui':
    ensure => $package_ensure,
    name   => $::tuskar::params::ui_package_name,
  }

  if $extras {
    package { 'tuskar-ui-extras':
      ensure => $package_ensure,
      name   => $::tuskar::params::ui_extras_package_name,
    }
  }

}
