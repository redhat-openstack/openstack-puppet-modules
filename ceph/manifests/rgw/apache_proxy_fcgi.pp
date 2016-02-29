#
# Copyright (C) 2016 Mirantis Inc.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
# Author: Oleksiy Molchanov <omolchanov@mirantis.com>
#
# Configures a ceph radosgw apache frontend with mod_proxy.
#
## == Define: ceph::rgw::apache_proxy_fcgi
#
# The RGW id. An alphanumeric string uniquely identifying the RGW.
# ( example: radosgw.gateway )
#
### == Parameters
#
# [*admin_email*] Admin email for the radosgw reports.
#   Optional. Default is 'root@localhost'.
#
# [*docroot*] Location of the apache docroot.
#   Optional. Default is '/var/www'.
#
# [*rgw_port*] Port the rados gateway listens.
#   Optional. Default is 80.
#
# [*rgw_dns_name*] Hostname to use for the service.
#   Optional. Default is $fqdn.
#
# [*rewrite_rule*] RewriteRule for the apache config.
#   Optional. Default is '.* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization},L]'.
#
# [*setenv*] String or aray for the apache setenv directive.
#   Optional. Default is 'proxy-nokeepalive 1'.
#
# [*proxy_pass*] Hash that contains local virtual path and remote url.
#   Optional. Default is {'path' => '/', 'url' => 'fcgi://127.0.0.1:9000/'}.
#
# [*syslog*] Whether or not to log to syslog.
#   Optional. Default is true.
#
define ceph::rgw::apache_proxy_fcgi (
  $admin_email     = 'root@localhost',
  $docroot         = '/var/www',
  $rgw_dns_name    = $::fqdn,
  $rgw_port        = 80,
  $rewrite_rule    = '.* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization},L]',
  $setenv          = 'proxy-nokeepalive 1',
  $proxy_pass      = {'path' => '/', 'url' => 'fcgi://127.0.0.1:9000/'},
  $syslog          = true,
) {

  class { '::apache':
    default_mods  => false,
    default_vhost => false,
  }
  include ::apache::mod::alias
  include ::apache::mod::auth_basic
  include ::apache::mod::mime
  include ::apache::mod::rewrite
  include ::apache::mod::proxy
  ::apache::mod { 'proxy_fcgi': }
  ::apache::mod { 'env': }

  apache::vhost { "${rgw_dns_name}-radosgw":
    servername   => $rgw_dns_name,
    serveradmin  => $admin_email,
    docroot      => $docroot,
    access_log   => $syslog,
    error_log    => $syslog,
    port         => $rgw_port,
    rewrite_rule => $rewrite_rule,
    setenv       => $setenv,
    proxy_pass   => $proxy_pass,
  }
}
