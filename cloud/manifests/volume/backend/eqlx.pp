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
# Configure Dell EqualLogic backend for Cinder
#
#
# === Parameters
#
# [*san_ip*]
#   (required) The IP address of the Dell EqualLogic array.
#
# [*san_login*]
#   (required) The account to use for issuing SSH commands.
#
# [*san_password*]
#   (required) The password for the specified SSH account.
#
# [*san_thin_provision*]
#   (optional) Whether or not to use thin provisioning for volumes.
#   Defaults to true
#
# [*volume_backend_name*]
#   (optional) The backend name.
#   Defaults to the name of the resource
#
# [*eqlx_group_name*]
#   (optional) The CLI prompt message without '>'.
#   Defaults to 'group-0'
#
# [*eqlx_pool*]
#   (optional) The pool in which volumes will be created.
#   Defaults to 'default'
#
# [*eqlx_use_chap*]
#   (optional) Use CHAP authentification for targets?
#   Defaults to false
#
# [*eqlx_chap_login*]
#   (optional) An existing CHAP account name.
#   Defaults to 'chapadmin'
#
# [*eqlx_chap_password*]
#   (optional) The password for the specified CHAP account name.
#   Defaults to '12345'
#
# [*eqlx_cli_timeout*]
#   (optional) The timeout for the Group Manager cli command execution.
#   Defaults to 30 seconds
#
# [*eqlx_cli_max_retries*]
#   (optional) The maximum retry count for reconnection.
#   Defaults to 5
#
define cloud::volume::backend::eqlx (
  $san_ip,
  $san_login,
  $san_password,
  $san_thin_provision   = true,
  $volume_backend_name  = $name,
  $eqlx_group_name      = 'group-0',
  $eqlx_pool            = 'default',
  $eqlx_use_chap        = false,
  $eqlx_chap_login      = 'chapadmin',
  $eqlx_chap_password   = '12345',
  $eqlx_cli_timeout     = 30,
  $eqlx_cli_max_retries = 5,
) {

  cinder::backend::eqlx { $name:
    san_ip               => $san_ip,
    san_login            => $san_login,
    san_password         => $san_password,
    san_thin_provision   => $san_thin_provision,
    eqlx_group_name      => $eqlx_group_name,
    eqlx_pool            => $eqlx_pool,
    eqlx_use_chap        => $eqlx_use_chap,
    eqlx_chap_login      => $eqlx_chap_login,
    eqlx_chap_password   => $eqlx_chap_password,
    eqlx_cli_timeout     => $eqlx_cli_timeout,
    eqlx_cli_max_retries => $eqlx_cli_max_retries,
  }

  @cinder::type { $volume_backend_name:
    set_key   => 'volume_backend_name',
    set_value => $volume_backend_name,
    notify    => Service['cinder-volume']
  }
}
