# == Class: tuskar::config
#
# This class is used to manage arbitrary Tuskar configurations.
#
# === Parameters
#
# [*tuskar_config*]
#   (optional) Allow configuration of arbitrary Tuskar configurations.
#   The value is an hash of tuskar_config resources. Example:
#   { 'DEFAULT/foo' => { value => 'fooValue'},
#     'DEFAULT/bar' => { value => 'barValue'}
#   }
#   In yaml format, Example:
#   tuskar_config:
#     DEFAULT/foo:
#       value: fooValue
#     DEFAULT/bar:
#       value: barValue
#
#   NOTE: The configuration MUST NOT be already handled by this module
#   or Puppet catalog compilation will fail with duplicate resources.
#
class tuskar::config (
  $tuskar_config        = {},
) {

  validate_hash($tuskar_config)

  create_resources('tuskar_config', $tuskar_config)
}
