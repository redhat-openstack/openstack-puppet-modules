# == Class: contrail::webui::config
#
# Configure the webui service
#
# === Parameters:
#
# [*openstack_vip*]
#   (optional) VIP for the Openstack services
#   Defaults to '127.0.0.1'
#
# [*contrail_vip*]
#   (optional) VIP for the Contrail services
#   Defaults to '127.0.0.1'
#
# [*cassandra_ip*]
#   (optional) Array of Cassandra IPs
#   Defaults to ['127.0.0.1']
#
# [*redis_ip*]
#   (optional) Redis IP
#   Defaults to '127.0.0.1'
#
# [*contrail_webui_http_port*]
#   (optional) Port of the Contrail WebUI when using HTTP
#   Defaults to 8080
#
# [*contrail_webui_https_port*]
#   (optional) Port of the Contrail WebUI when using HTTPS
#   Defaults to 8143
#
class contrail::webui::config (
  $openstack_vip             = '127.0.0.1',
  $contrail_vip              = '127.0.0.1',
  $cassandra_ip              = ['127.0.0.1'],
  $redis_ip                  = '127.0.0.1',
  $contrail_webui_http_port  = '8080',
  $contrail_webui_https_port = '8143',
) {

  file { '/etc/contrail/config.global.js' :
    ensure  => file,
    content => template('contrail/config.global.js.erb'),
  }

}
