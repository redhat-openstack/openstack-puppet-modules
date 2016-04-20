# == Class: aodh::policy
#
# Configure the aodh policies
#
# === Parameters
#
# [*policies*]
#   (optional) Set of policies to configure for aodh
#   Example :
#     {
#       'aodh-context_is_admin' => {
#         'key' => 'context_is_admin',
#         'value' => 'true'
#       },
#       'aodh-default' => {
#         'key' => 'default',
#         'value' => 'rule:admin_or_owner'
#       }
#     }
#   Defaults to empty hash.
#
# [*policy_path*]
#   (optional) Path to the nova policy.json file
#   Defaults to /etc/aodh/policy.json
#
class aodh::policy (
  $policies    = {},
  $policy_path = '/etc/aodh/policy.json',
) {

  validate_hash($policies)

  Openstacklib::Policy::Base {
    file_path => $policy_path,
  }

  create_resources('openstacklib::policy::base', $policies)
}
