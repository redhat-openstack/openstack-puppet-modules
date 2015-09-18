# == Class: aodh::config
#
# This class is used to manage arbitrary aodh configurations.
#
# === Parameters
#
# [*aodh_config*]
#   (optional) Allow configuration of arbitrary aodh configurations.
#   The value is an hash of aodh_config resources. Example:
#   { 'DEFAULT/foo' => { value => 'fooValue'},
#     'DEFAULT/bar' => { value => 'barValue'}
#   }
#   In yaml format, Example:
#   aodh_config:
#     DEFAULT/foo:
#       value: fooValue
#     DEFAULT/bar:
#       value: barValue
#
#   NOTE: The configuration MUST NOT be already handled by this module
#   or Puppet catalog compilation will fail with duplicate resources.
#
class aodh::config (
  $aodh_config = {},
) {

  validate_hash($aodh_config)

  create_resources('aodh_config', $aodh_config)
}
