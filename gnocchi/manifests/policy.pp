# == Class: gnocchi::policy
#
# Configure the gnocchi policies
#
# === Parameters
#
# [*policies*]
#   (optional) Set of policies to configure for gnocchi
#   Example :
#     {
#       'gnocchi-context_is_admin' => {
#         'key' => 'context_is_admin',
#         'value' => 'true'
#       },
#       'gnocchi-default' => {
#         'key' => 'default',
#         'value' => 'rule:admin_or_owner'
#       }
#     }
#   Defaults to empty hash.
#
# [*policy_path*]
#   (optional) Path to the nova policy.json file
#   Defaults to /etc/gnocchi/policy.json
#
class gnocchi::policy (
  $policies    = {},
  $policy_path = '/etc/gnocchi/policy.json',
) {

  validate_hash($policies)

  Openstacklib::Policy::Base {
    file_path => $policy_path,
  }

  create_resources('openstacklib::policy::base', $policies)

}
