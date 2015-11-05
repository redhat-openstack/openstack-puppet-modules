# == Class: contrail::vnc_api
#
# Install the /etc/contrail/vnc_api_lib.ini
#
# === Parameters:
#
# [*vnc_api_config*]
#   (optional) Hash of parameters for /etc/contrail/vnc_api_lib.ini
#   Defaults to {}
#
class contrail::vnc_api (
  $vnc_api_config = {},
) {

  validate_hash($vnc_api_config)

  create_resources('contrail_vnc_api_config', $vnc_api_config)

}
