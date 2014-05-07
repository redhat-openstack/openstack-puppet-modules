# == Public class: kibana3
#
# Installs and configures kibana3.
#
# === Parameters
# [*ensure*]
#   Set to 'absent' to uninstall. Beware, if $manage_git or $manage_ws are set
#   to 'true' their respective modules will also be set to 'absent'.
#
# [*config_default_route*]
#   This is the default landing page when you don't specify a dashboard to
#   load. You can specify files, scripts or saved dashboards here. For example,
#   if you had saved a dashboard called `WebLogs' to elasticsearch you might
#   use:
#   default_route => '/dashboard/elasticsearch/WebLogs',
#
# [*config_es_port*]
#   The port of the elasticsearch server. Because kibana3 is browser based
#   this must be accessible from the browser loading kibana3.
#
# [*config_es_protocol*]
#   The protocol (http/https) of the elasticsearch server. Because kibana3 is
#   browser based this must be accessible from the browser loading kibana3.
#
# [*config_es_server*]
#   The FQDN of the elasticsearch server. Because kibana3 is browser based
#   this must be accessible from the browser loading kibana3.
#
# [*config_kibana_index*]
#   The default ES index to use for storing Kibana specific object such as
#   stored dashboards.
#
# [*config_panel_names*]
#   An array of panel modules available. Panels will only be loaded when they
#   are defined in the dashboard, but this list is used in the "add panel"
#   interface.
#
# [*k3_folder_owner*]
#   The owner of the kibana3 install located at $k3_install_folder.
#
# [*k3_install_folder*]
#   The folder to install kibana3 into.
#
# [*k3_release*]
#   A tag or branch from the https://github.com/elasticsearch/kibana repo. Note
#   that you should use the commit hash instead of the tag name (see issue #5)
#   or puppet will overwrite the config.js file.
#
# [*manage_git*]
#   Should the module manage git.
#
# [*manage_ws*]
#   Should the module manage the webserver.
#
# [*ws_port*]
#   Change the default port for the webserver to a custom value. Only taken
#   into account if manage_ws => true.
#
# === Examples
#
#  class { 'kibana3':
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Alejandro Figueroa <alejandro@ideasftw.com>
#
# === Copyright
#
# Copyright 2014 Alejandro Figueroa, unless otherwise noted.
#
class kibana3 (
  $ensure = $::kibana3::params::ensure,

  $config_default_route = $::kibana3::params::config_default_route,
  $config_es_port       = $::kibana3::params::config_es_port,
  $config_es_protocol   = $::kibana3::params::config_es_protocol,
  $config_es_server     = $::kibana3::params::config_es_server,
  $config_kibana_index  = $::kibana3::params::config_kibana_index,
  $config_panel_names   = $::kibana3::params::config_panel_names,

  $k3_folder_owner   = $::kibana3::params::k3_folder_owner,
  $k3_install_folder = $::kibana3::params::k3_install_folder,
  $k3_release        = $::kibana3::params::k3_release,

  $manage_git = $::kibana3::params::manage_git,

  $manage_ws = $::kibana3::params::manage_ws,
  $ws_port   = $::kibana3::params::ws_port,

) inherits kibana3::params {

  validate_string($ensure,$config_default_route,$config_es_port,
    $config_es_protocol,$config_es_server,$config_kibana_index,
    $k3_folder_owner,$k3_install_folder,$k3_release,$ws_port)

  validate_bool($manage_git,$manage_ws)

  validate_array($config_panel_names)

  case $ensure {
    'present': {
      class { 'kibana3::install': } ->
      class { 'kibana3::config': }
    }
    'absent': {
      class { 'kibana3::uninstall': }
    }
    default: {
      fail("${ensure} is not supported for ensure.
        Allowed values are 'present' and 'absent'.")
    }
  }
}
