# == Class: manila::nova
#
# Setup and configure Nova communication
#
# === Parameters
#
# [*nova_catalog_info*]
# (optional) Info to match when looking for nova in the service
# catalog. Format is : separated values of the form:
# <service_type>:<service_name>:<endpoint_type>
#
# [*nova_catalog_admin_info*]
# (optional) Same as nova_catalog_info, but for admin endpoint.
#
# [*os_region_name*]
# (optional) region name of this node
#
# [*nova_ca_certificates_file*]
# (optional) Location of ca certicates file to use for nova client
# requests.
#
# [*nova_api_insecure*]
# (optional) Allow to perform insecure SSL requests to nova
#
# [*nova_admin_username*]
# (optional) Nova admin username
#
# [*nova_admin_password*]
# (optional) Nova admin password
#
# [*nova_admin_tenant_name*]
# (optional) Nova admin tenant name
#
# [*nova_admin_auth_url*]
# (optional) Identity service url
#

class manila::compute::nova (
  $nova_catalog_info         = 'compute:nova:publicURL',
  $nova_catalog_admin_info   = 'compute:nova:adminURL',
  $nova_ca_certificates_file = undef,
  $nova_api_insecure         = false,
  $nova_admin_username       = 'nova',
  $nova_admin_password       = undef,
  $nova_admin_tenant_name    = 'service',
  $nova_admin_auth_url       = 'http://localhost:5000/v2.0',
) {

manila_config {
  'DEFAULT/nova_catalog_info':        value => $nova_catalog_info;
  'DEFAULT/nova_catalog_admin_info':  value => $nova_catalog_admin_info;
  'DEFAULT/nova_ca_certificates_file':value => $nova_ca_certificates_file;
  'DEFAULT/nova_api_insecure':        value => $nova_api_insecure;
  'DEFAULT/nova_admin_username':      value => $nova_admin_username;
  'DEFAULT/nova_admin_password':      value => $nova_admin_password;
  'DEFAULT/nova_admin_tenant_name':   value => $nova_admin_tenant_name;
  'DEFAULT/nova_admin_auth_url':      value => $nova_admin_auth_url;
  }
}
