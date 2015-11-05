# == Class: contrail::config::config
#
# Configure the config service
#
# === Parameters:
#
# [*api_config*]
#   (optional) Hash of parameters for /etc/contrail/contrail-api.conf
#   Defaults to {}
#
# [*alarm_gen_config*]
#   (optional) Hash of parameters for /etc/contrail/contrail-alarm-gen.conf
#   Defaults to {}
#
# [*config_nodemgr_config*]
#   (optional) Hash of parameters for /etc/contrail/contrail-config-nodemgr.conf
#   Defaults to {}
#
# [*discovery_config*]
#   (optional) Hash of parameters for /etc/contrail/contrail-discovery.conf
#   Defaults to {}
#
# [*schema_config*]
#   (optional) Hash of parameters for /etc/contrail/contrail-schema.conf
#   Defaults to {}
#
# [*device_manager_config*]
#   (optional) Hash of parameters for /etc/contrail/contrail-device-managerr.conf
#   Defaults to {}
#
# [*svc_monitor_config*]
#   (optional) Hash of parameters for /etc/contrail/contrail-svc-monitor.conf
#   Defaults to {}
#
# [*basicauthusers_property*]
#   (optional) List of pairs of ifmap users. Example: user1:password1
#   Defaults to []
#
class contrail::config::config (
  $api_config              = {},
  $alarm_gen_config        = {},
  $config_nodemgr_config   = {},
  $discovery_config        = {},
  $schema_config           = {},
  $device_manager_config   = {},
  $svc_monitor_config      = {},
  $basicauthusers_property = [],
) {

  validate_hash($api_config)
  validate_hash($alarm_gen_config)
  validate_hash($config_nodemgr_config)
  validate_hash($discovery_config)
  validate_hash($schema_config)
  validate_hash($device_manager_config)
  validate_hash($svc_monitor_config)

  validate_array($basicauthusers_property)

  create_resources('contrail_api_config', $api_config)
  create_resources('contrail_alarm_gen_config', $alarm_gen_config)
  create_resources('contrail_config_nodemgr_config', $config_nodemgr_config)
  create_resources('contrail_discovery_config', $discovery_config)
  create_resources('contrail_schema_config', $schema_config)
  create_resources('contrail_device_manager_config', $device_manager_config)
  create_resources('contrail_svc_monitor_config', $svc_monitor_config)

  file { '/etc/ifmap-server/basicauthusers.properties' :
    ensure  => file,
    content => template('contrail/config/basicauthusers.properties.erb'),
  }

  file {'/etc/ifmap-server/log4j.properties' :
    ensure  => file,
    content => template('contrail/config/log4j.properties.erb'),
  }

}

