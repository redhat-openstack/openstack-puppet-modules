# = Private class: kibana3::params
#
# Author: Alejandro Figueroa
class kibana3::params {
  $ensure = 'present'

  $config_default_route = '/dashboard/file/default.json'
  $config_es_port       = '9200'
  $config_es_protocol   = 'http'
  $config_es_server     = '"+window.location.hostname+"'
  $config_kibana_index  = 'kibana-int'
  $config_panel_names   = [
    'histogram',
    'map',
    'goal',
    'table',
    'filtering',
    'timepicker',
    'text',
    'hits',
    'column',
    'trends',
    'bettermap',
    'query',
    'terms',
    'stats',
    'sparklines'
  ]

  # If $k3_folder_owner remains 'undef' it defaults to one of two case:
  # if $manage_ws = 'false'; $k3_folder_owner = 'root'
  # if $manage_ws = 'true'; $k3_folder_owner = $::apache::params::user
  $k3_folder_owner   = undef
  $k3_install_folder = '/opt/kibana3'
  $k3_release        = 'a50a913'

  $manage_git = true

  $manage_ws = true
  $ws_port   = '80'
}
