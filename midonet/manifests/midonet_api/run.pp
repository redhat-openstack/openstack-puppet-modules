# == Class: midonet::midonet_api::run
# Check out the midonet::midonet_api class for a full understanding of
# how to use the midonet_api resource
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
class midonet::midonet_api::run (
  $zk_servers,
  $keystone_auth,
  $vtep,
  $tomcat_package,
  $api_ip,
  $api_port,
  $keystone_host,
  $keystone_port,
  $keystone_admin_token,
  $keystone_tenant_name,
  $catalina_base,
  $bind_address
) {

    tomcat::instance{'midonet-api':
      package_name => $tomcat_package,
    } ->

    tomcat::config::server::connector {'HTTP/1.1':
      port                  => $api_port,
      catalina_base         => $catalina_base,
      connector_ensure      => 'present',
      additional_attributes => {
        'address'           => $bind_address,
        'connectionTimeout' => '20000',
        'URIEncoding'       => 'UTF-8',
        'redirectPort'      => '8443',
        'maxHttpHeaderSize' => '65536'
      },
      require               => Tomcat::Instance['midonet-api'],
      notify                => Service[$tomcat_package]
    }

    file {"/etc/${tomcat_package}/Catalina/localhost/midonet-api.xml":
      ensure  => present,
      source  => 'puppet:///modules/midonet/midonet-api/midonet-api.xml',
      owner   => 'root',
      group   => 'root',
      require => Tomcat::Instance['midonet-api'],
      notify  => Service[$tomcat_package]
    }

    file {'/usr/share/midonet-api/WEB-INF/web.xml':
      ensure  => present,
      content => template('midonet/midonet-api/web.xml.erb'),
      require => Package['midonet-api'],
      notify  => Service[$tomcat_package]
    }

    service {$tomcat_package:
      ensure  => running,
      enable  => true,
      require => [File['/usr/share/midonet-api/WEB-INF/web.xml'],
                  Tomcat::Config::Server::Connector['HTTP/1.1']]
    }
}
