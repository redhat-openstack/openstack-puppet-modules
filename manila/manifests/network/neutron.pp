# == class: manila::network::neutron
#
# Setup and configure Neutron communication
#
# === Parameters
#
# [*neutron_url*]
# (optional) URL for connecting to neutron
#
# [*neutron_url_timeout*]
# (optional) timeout value for connecting to neutron in seconds
#
# [*neutron_admin_username*]
# (optional) username for connecting to neutron in admin context
#
# [*neutron_admin_password*]
# (optional) password for connecting to neutron in admin context
#
# [*neutron_admin_tenant_name*]
# (optional) Tenant name for connecting to neutron in admin context
#
# [*neutron_region_name*]
# (optional) region name for connecting to neutron in admin context
#
# [*neutron_admin_auth_url*]
# (optional) auth url for connecting to neutron in admin context
#
# [*neutron_api_insecure*]
# (optional) if set, ignore any SSL validation issues
#
# [*neutron_auth_strategy*]
# (optional) auth strategy for connecting to
# neutron in admin context
#
# [*neutron_ca_certificates_file*]
# (optional) Location of ca certificates file to use for
# neutron client requests.
#

class manila::network::neutron (
  $neutron_url                  = 'http://127.0.0.1:9696',
  $neutron_url_timeout          = 30,
  $neutron_admin_username       = 'neutron',
  $neutron_admin_password       = undef,
  $neutron_admin_tenant_name    = 'service',
  $neutron_region_name          = undef,
  $neutron_admin_auth_url       = 'http://localhost:5000/v2.0',
  $neutron_api_insecure         = false,
  $neutron_auth_strategy        = 'keystone',
  $neutron_ca_certificates_file = undef,
) {

  $neutron_plugin_name = 'manila.network.neutron.neutron_network_plugin.NeutronNetworkPlugin'

  manila_config {
    'DEFAULT/network_api_class':            value => $neutron_plugin_name;
    'DEFAULT/neutron_url':                  value => $neutron_url;
    'DEFAULT/neutron_url_timeout':          value => $neutron_url_timeout;
    'DEFAULT/neutron_admin_username':       value => $neutron_admin_username;
    'DEFAULT/neutron_admin_password':       value => $neutron_admin_password;
    'DEFAULT/neutron_admin_tenant_name':    value => $neutron_admin_tenant_name;
    'DEFAULT/neutron_region_name':          value => $neutron_region_name;
    'DEFAULT/neutron_admin_auth_url':       value => $neutron_admin_auth_url;
    'DEFAULT/neutron_api_insecure':         value => $neutron_api_insecure;
    'DEFAULT/neutron_auth_strategy':        value => $neutron_auth_strategy;
    'DEFAULT/neutron_ca_certificates_file': value => $neutron_ca_certificates_file;
    }
}
