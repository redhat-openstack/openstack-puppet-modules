# == Class: midonet::midonet_api
#
# Install and run midonet_api
#
# === Parameters
#
# [*zk_servers*]
#   List of hash [{ip, port}] Zookeeper instances that run in cluster.
# [*keystone_auth*]
#   Whether to authenticate the API request through a Keystone service. Default:
#   false.
# [*vtep*]
#   Whether to enable the vtep service endpoint. Default: false
# [*tomcat_package*]
#   The name of the tomcat package to install. The module already inserts a
#   value depending on the distribution used. Don't override it unless you know
#   what you are doing.
# [*api_ip*]
#   Exposed IP address. By default, it exposes the first internet address that
#   founds in the host.
# [*api_port*]
#   TCP listening port. By default, 8080
# [*keystone_host*]
#   Keystone service endpoint IP. Not used if keystone_auth is false.
# [*keystone_port*]
#   Keystone service endpoint port. Not used if keystone_auth is false.
# [*keystone_admin_token*]
#   Keystone admin token. Not used if keystone_auth is false.
# [*keystone_tenant_name*]
#   Keystone tenant name. 'admin' by default. Not used if keystone_auth is false.
#
# === Examples
#
# The easiest way to run this class is:
#
#     include midonet::midonet_api
#
# This call assumes that there is a zookeeper running in the target host and the
# module will spawn a midonet_api without keystone authentication.
#
# This is a quite naive deployment, just for demo purposes. A more realistic one
# would be:
#
#    class {'midonet::midonet_api':
#        zk_servers           =>  [{'ip'   => 'host1',
#                             'port' => '2183'},
#                            {'ip'   => 'host2'}],
#        keystone_auth        => true,
#        vtep                 => true,
#        api_ip               => '92.234.12.4',
#        keystone_host        => '92.234.12.9',
#        keystone_port        => 35357  (35357 is already the default)
#        keystone_admin_token => 'arrakis',
#        keystone_tenant_name => 'other-than-admin' ('admin' by default)
#    }
#
# You can alternatively use the Hiera.yaml style:
#
# midonet::midonet_api::zk_servers:
#     - ip: 'host1'
#       port: 2183
#     - ip: 'host2'
# midonet::midonet_api::vtep: true
# midonet::midonet_api::keystone_auth: true
# midonet::midonet_api::api_ip: '92.234.12.4'
# midonet::midonet_api::keystone_host: '92.234.12.9'
# midonet::midonet_api::keystone_port: 35357
# midonet::midonet_api::keystone_admin_token: 'arrakis'
# midonet::midonet_api::keystone_tenant_name: 'admin'
#
# Please note that Zookeeper port is not mandatory and defaulted to 2181.
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
class midonet::midonet_api(
  $zk_servers,
  $keystone_auth,
  $vtep,
  $tomcat_package,
  $keystone_host=$::ipaddress,
  $keystone_port=35357,
  $keystone_admin_token=undef,
  $keystone_tenant_name='admin',
  $api_ip=$::ipaddress,
  $api_port='8080',
  $catalina_base) {

    include midonet::midonet_api::augeas

    class {'midonet::midonet_api::install': }

    class {'midonet::midonet_api::run':
        zk_servers           => $zk_servers,
        keystone_auth        => $keystone_auth,
        tomcat_package       => $tomcat_package,
        vtep                 => $vtep,
        api_ip               => $api_ip,
        api_port             => $api_port,
        keystone_host        => $keystone_host,
        keystone_port        => $keystone_port,
        keystone_admin_token => $keystone_admin_token,
        keystone_tenant_name => $keystone_tenant_name,
        catalina_base        => $catalina_base
    }
}
