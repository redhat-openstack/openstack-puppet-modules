# == define: manila::backend::netapp
#
# Configures Manila to use the NetApp unified share driver
# Compatible for multiple backends
#
# === Parameters
# NTAP: check if these parameters are actually optional or required
#
# [*share_backend_name*]
#   (optional) Name of the backend in manila.conf that
#   these settings will reside in
#
# [*netapp_nas_transport_type*]
#   (optional) The transport protocol used when communicating with ONTAPI on the
#   storage system or proxy server. Valid values are http or https.
#   Defaults to http
#
# [*netapp_nas_login*]
#   (required) Administrative user account name used to access the storage
#   system or proxy server.
#
# [*netapp_nas_password*]
#   (required) Password for the administrative user account specified in the
#   netapp_nas_login parameter.
#
# [*netapp_nas_server_hostname*]
#   (required) The hostname (or IP address) for the storage system or proxy
#   server.
#
# [*netapp_nas_volume_name_template*]
#   (optional) NetApp volume name template.
#
# [*netapp_vserver_name_template*]
#   (optional) Name template to use for new vserver.
#
# [*netapp_lif_name_template*]
#   (optional) Lif name template
#
# [*netapp_aggregate_name_search_pattern*]
#   (optional) Pattern for searching available aggregates
#   for provisioning.
#
# [*netapp_root_volume_aggregate*]
#   (optional) Name of aggregate to create root volume on.
#
# [*netapp_root_volume_name*]
#   (optional) Root volume name.
#
# === Examples
#
#  manila::backend::netapp { 'myBackend':
#    netapp_nas_login           => 'clusterAdmin',
#    netapp_nas_password        => 'password',
#    netapp_nas_server_hostname => 'netapp.mycorp.com',
#    netapp_nas_transport_type  => 'https',
#  }

define manila::backend::netapp (
  $share_backend_name                   = $name,
  $netapp_nas_transport_type            = 'http',
  $netapp_nas_login                     = 'admin',
  $netapp_nas_password                  = undef,
  $netapp_nas_server_hostname           = undef,
  $netapp_nas_volume_name_template      = 'share_%(share_id)s',
  $netapp_vserver_name_template         = 'os_%s',
  $netapp_lif_name_template             = 'os_%(net_allocation_id)s',
  $netapp_aggregate_name_search_pattern  = '(.*)',
  $netapp_root_volume_aggregate         = undef,
  $netapp_root_volume_name              = 'root',
) {

  $netapp_share_driver = 'manila.share.drivers.netapp.cluster_mode.NetAppClusteredShareDriver'

  manila_config {
    'DEFAULT/enabled_share_backends':                             value => $share_backend_name;
    "${share_backend_name}/share_backend_name":                   value => $share_backend_name;
    "${share_backend_name}/share_driver":                         value => $netapp_share_driver;
    "${share_backend_name}/netapp_nas_transport_type":            value => $netapp_nas_transport_type;
    "${share_backend_name}/netapp_nas_login":                     value => $netapp_nas_login;
    "${share_backend_name}/netapp_nas_password":                  value => $netapp_nas_password, secret => true;
    "${share_backend_name}/netapp_nas_server_hostname":           value => $netapp_nas_server_hostname;
    "${share_backend_name}/netapp_nas_volume_name_template":      value => $netapp_nas_volume_name_template;
    "${share_backend_name}/netapp_vserver_name_template":         value => $netapp_vserver_name_template;
    "${share_backend_name}/netapp_lif_name_template":             value => $netapp_lif_name_template;
    "${share_backend_name}/netapp_aggregate_name_search_pattern": value => $netapp_aggregate_name_search_pattern;
    "${share_backend_name}/netapp_root_volume_aggregate":         value => $netapp_root_volume_aggregate;
    "${share_backend_name}/netapp_root_volume_name":              value => $netapp_root_volume_name;
  }

  package { 'nfs-utils': ensure => present }
}
