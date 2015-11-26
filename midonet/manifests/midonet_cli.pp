# == Class: midonet::midonet_cli
#
# Install midonet_cli
#
# === Parameters
#
# No parameters
#
# === Examples
#
# Just declare the class and the package will be installed
#
# === Authors
#
# Midonet (http://midonet.org)
#
# === Copyright
#
# Copyright (c) 2015 Midokura SARL, All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
class midonet::midonet_cli(
  $api_endpoint='http://127.0.0.1:8080/midonet-api',
  $username='admin',
  $password='admin',
  $tenant_name='admin',
) {

  package {'python-midonetclient':
    ensure  => present,
  }

  midonet_client_conf {
    'cli/api_url':    value => $api_endpoint;
    'cli/username':   value => $username;
    'cli/password':   value => $password;
    'cli/project_id': value => $tenant_name;
  }

}
