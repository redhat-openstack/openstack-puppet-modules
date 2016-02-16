# == Class: gnocchi::config
#
# This class is used to manage arbitrary gnocchi configurations.
#
# === Parameters
#
# [*gnocchi_config*]
#   (optional) Allow configuration of arbitrary gnocchi configurations.
#   The value is an hash of gnocchi_config resources. Example:
#   { 'DEFAULT/foo' => { value => 'fooValue'},
#     'DEFAULT/bar' => { value => 'barValue'}
#   }
#   In yaml format, Example:
#   gnocchi_config:
#     DEFAULT/foo:
#       value: fooValue
#     DEFAULT/bar:
#       value: barValue
#
# [*gnocchi_api_paste_ini*]
#   (optional) Allow configuration of /etc/gnocchi/api-paste.ini options.
#
#   NOTE: The configuration MUST NOT be already handled by this module
#   or Puppet catalog compilation will fail with duplicate resources.
#
class gnocchi::config (
  $gnocchi_config        = {},
  $gnocchi_api_paste_ini = {},
) {

  validate_hash($gnocchi_config)
  validate_hash($gnocchi_api_paste_ini)

  create_resources('gnocchi_config', $gnocchi_config)
  create_resources('gnocchi_api_paste_ini', $gnocchi_api_paste_ini)
}
