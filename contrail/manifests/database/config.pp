# == Class: contrail::database::config
#
# Configure the database service
#
# === Parameters:
#
# [*database_nodemgr_config*]
#   (optional) Hash of parameters for /etc/contrail/contrail-database-nodemgr.conf
#   Defaults to {}
#
class contrail::database::config (
  $database_nodemgr_config = {},
) {

  validate_hash($database_nodemgr_config)

  create_resources('contrail_database_nodemgr_config', $database_nodemgr_config)

}
