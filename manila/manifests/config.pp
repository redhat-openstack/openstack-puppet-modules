# == Class: manila::config
#
# This class is used to manage arbitrary manila configurations.
#
# === Parameters
#
# [*xxx_config*]
#   (optional) Allow configuration of arbitrary manila configurations.
#   The value is an hash of xxx_config resources. Example:
#   { 'DEFAULT/foo' => { value => 'fooValue'},
#     'DEFAULT/bar' => { value => 'barValue'}
#   }
#
#   In yaml format, Example:
#   xxx_config:
#     DEFAULT/foo:
#       value: fooValue
#     DEFAULT/bar:
#       value: barValue
#
# [*manila_config*]
#   (optional) Allow configuration of manila.conf configurations.
#
# [*api_paste_ini_config*]
#   (optional) Allow configuration of /etc/manila/api-paste.ini configurations.
#
#   NOTE: The configuration MUST NOT be already handled by this module
#   or Puppet catalog compilation will fail with duplicate resources.
#
class manila::config (
  $manila_config         = {},
  $api_paste_ini_config  = {},
) {
  validate_hash($manila_config)
  validate_hash($api_paste_ini_config)

  create_resources('manila_config', $manila_config)
  create_resources('manila_api_paste_ini', $api_paste_ini_config)
}
