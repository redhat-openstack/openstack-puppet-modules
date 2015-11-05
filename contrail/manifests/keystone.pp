# == Class: contrail::keystone
#
# Install the /etc/contrail/contrail-keystone-auth.conf
#
# === Parameters:
#
# [*keystone_config*]
#   (optional) Hash of parameters for /etc/contrail/contrail-keystone-auth.conf
#   Defaults to {}
#
class contrail::keystone (
  $keystone_config = {},
) {

  validate_hash($keystone_config)

  create_resources('contrail_keystone_config', $keystone_config)

}
