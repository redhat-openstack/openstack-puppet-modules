# == Class: contrail::analytics::config
#
# Configure the analytics service
#
# === Parameters:
#
# [*analytics_api_config*]
#   (optional) Hash of parameters for /etc/contrail/contrail-analytics-api.conf
#   Defaults to {}
#
# [*collector_config*]
#   (optional) Hash of parameters for /etc/contrail/contrail-collector.conf
#   Defaults to {}
#
# [*query_engine_config*]
#   (optional) Hash of parameters for /etc/contrail/contrail-query-engine.conf
#   Defaults to {}
#
# [*snmp_collector_config*]
#   (optional) Hash of parameters for /etc/contrail/contrail-snmp-collector.conf
#   Defaults to {}
#
# [*analytics_nodemgr_config*]
#   (optional) Hash of parameters for /etc/contrail/contrail-analytics-nodemgr.conf
#   Defaults to {}
#
# [*topology_config*]
#   (optional) Hash of parameters for /etc/contrail/contrail-toplogy.conf
#   Defaults to {}
#
class contrail::analytics::config (
  $analytics_api_config     = {},
  $collector_config         = {},
  $query_engine_config      = {},
  $snmp_collector_config    = {},
  $analytics_nodemgr_config = {},
  $topology_config          = {},
) {

  validate_hash($analytics_api_config)
  validate_hash($collector_config)
  validate_hash($query_engine_config)
  validate_hash($snmp_collector_config)
  validate_hash($analytics_nodemgr_config)
  validate_hash($topology_config)

  create_resources('contrail_analytics_api_config', $analytics_api_config)
  create_resources('contrail_collector_config', $collector_config)
  create_resources('contrail_query_engine_config', $query_engine_config)
  create_resources('contrail_snmp_collector_config', $snmp_collector_config)
  create_resources('contrail_analytics_nodemgr_config', $analytics_nodemgr_config)
  create_resources('contrail_topology_config', $topology_config)

}
