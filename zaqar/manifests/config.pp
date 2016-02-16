# == Class: zaqar::config
#
# This class is used to manage arbitrary zaqar configurations.
#
# === Parameters
#
# [*zaqar_config*]
#   (optional) Allow configuration of arbitrary zaqar configurations.
#   The value is an hash of zaqar_config resources. Example:
#   { 'DEFAULT/foo' => { value => 'fooValue'},
#     'DEFAULT/bar' => { value => 'barValue'}
#   }
#   In yaml format, Example:
#   zaqar_config:
#     DEFAULT/foo:
#       value: fooValue
#     DEFAULT/bar:
#       value: barValue
#
#   NOTE: The configuration MUST NOT be already handled by this module
#   or Puppet catalog compilation will fail with duplicate resources.
#
class zaqar::config (
  $zaqar_config = {},
) {

  validate_hash($zaqar_config)

  create_resources('zaqar_config', $zaqar_config)
}
