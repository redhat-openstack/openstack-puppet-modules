# == define: manila::backend::netapp
#
# Configures Manila to use the NetApp unified share driver
# Compatible for multiple backends
#
# === Parameters
#
# [*driver_handles_share_servers*]
#  (required) Denotes whether the driver should handle the responsibility of
#   managing share servers. This must be set to false if the driver is to
#   operate without managing share servers.
#
# [*netapp_login*]
#   (required) Administrative user account name used to access the storage
#   system.
#
# [*netapp_password*]
#   (required) Password for the administrative user account specified in the
#   netapp_login parameter.
#
# [*netapp_server_hostname*]
#   (required) The hostname (or IP address) for the storage system.
#
# [*share_backend_name*]
#   (optional) Name of the backend in manila.conf that
#   these settings will reside in
#
# [*netapp_transport_type*]
#   (optional) The transport protocol used when communicating with
#   the storage system or proxy server. Valid values are
#   http or https.
#   Defaults to http
#
# [*netapp_storage_family*]
#   (optional) The storage family type used on the storage system; valid
#   values are ontap_cluster for clustered Data ONTAP.
#   Defaults to ontap_cluster
#
# [*netapp_server_port*]
#   (optional) The TCP port to use for communication with the storage system
#   or proxy server. If not specified, Data ONTAP drivers will use 80 for HTTP
#   and 443 for HTTPS.
#
# [*netapp_volume_name_template*]
#   (optional) NetApp volume name template.
#   Defaults to share_%(share_id)s
#
# [*netapp_vserver*]
#   (optional) This option specifies the storage virtual machine (previously
#   called a Vserver) name on the storage cluster on which provisioning of
#   shared file systems should occur. This option only applies
#   when the option driver_handles_share_servers is set to False.
#
# [*netapp_vserver_name_template*]
#   (optional) Name template to use for new vserver. This option only applies
#   when the option driver_handles_share_servers is set to True.
#   Defaults to os_%s
#
# [*netapp_lif_name_template*]
#   (optional) Logical interface (LIF) name template. This option only applies
#   when the option driver_handles_share_servers is set to True.
#   Defaults to os_%(net_allocation_id)s
#
# [*netapp_aggregate_name_search_pattern*]
#   (optional) Pattern for searching available aggregates
#   for provisioning.
#   Defaults to (.*)
#
# [*netapp_root_volume_aggregate*]
#   (optional) Name of aggregate to create root volume on. This option only
#   applies when the option driver_handles_share_servers is set to True.
#
# [*netapp_root_volume_name*]
#   (optional) Root volume name. This option only applies when the option
#   driver_handles_share_servers is set to True.
#   Defaults to root
#
# [*netapp_port_name_search_pattern*]
#   (optional) Pattern for overriding the selection of network ports on which
#   to create Vserver LIFs.
#   Defaults to (.*)
#
# [*netapp_trace_flags*]
#   (optional) This option is a comma-separated list of options (valid values
#   include method and api) that controls which trace info is written to the
#   Manila logs when the debug level is set to True
#
# === Examples
#
#  manila::backend::netapp { 'myBackend':
#    driver_handles_share_servers => true,
#    netapp_login                 => 'clusterAdmin',
#    netapp_password              => 'password',
#    netapp_server_hostname       => 'netapp.mycorp.com',
#    netapp_storage_family        => 'ontap_cluster',
#    netapp_transport_type        => 'https',
#  }

define manila::backend::netapp (
  $driver_handles_share_servers,
  $netapp_login,
  $netapp_password,
  $netapp_server_hostname,
  $share_backend_name                    = $name,
  $netapp_transport_type                 = 'http',
  $netapp_storage_family                 = 'ontap_cluster',
  $netapp_server_port                    = undef,
  $netapp_volume_name_template           = 'share_%(share_id)s',
  $netapp_vserver                        = undef,
  $netapp_vserver_name_template          = 'os_%s',
  $netapp_lif_name_template              = 'os_%(net_allocation_id)s',
  $netapp_aggregate_name_search_pattern  = '(.*)',
  $netapp_root_volume_aggregate          = undef,
  $netapp_root_volume_name               = 'root',
  $netapp_port_name_search_pattern       = '(.*)',
  $netapp_trace_flags                    = undef,
) {

  validate_string($netapp_password)

  $netapp_share_driver = 'manila.share.drivers.netapp.common.NetAppDriver'

  manila_config {
    "${share_backend_name}/share_driver":                         value => $netapp_share_driver;
    "${share_backend_name}/driver_handles_share_servers":         value => $driver_handles_share_servers;
    "${share_backend_name}/netapp_login":                         value => $netapp_login;
    "${share_backend_name}/netapp_password":                      value => $netapp_password, secret => true;
    "${share_backend_name}/netapp_server_hostname":               value => $netapp_server_hostname;
    "${share_backend_name}/share_backend_name":                   value => $share_backend_name;
    "${share_backend_name}/netapp_transport_type":                value => $netapp_transport_type;
    "${share_backend_name}/netapp_storage_family":                value => $netapp_storage_family;
    "${share_backend_name}/netapp_server_port":                   value => $netapp_server_port;
    "${share_backend_name}/netapp_volume_name_template":          value => $netapp_volume_name_template;
    "${share_backend_name}/netapp_vserver":                       value => $netapp_vserver;
    "${share_backend_name}/netapp_vserver_name_template":         value => $netapp_vserver_name_template;
    "${share_backend_name}/netapp_lif_name_template":             value => $netapp_lif_name_template;
    "${share_backend_name}/netapp_aggregate_name_search_pattern": value => $netapp_aggregate_name_search_pattern;
    "${share_backend_name}/netapp_root_volume_aggregate":         value => $netapp_root_volume_aggregate;
    "${share_backend_name}/netapp_root_volume_name":              value => $netapp_root_volume_name;
    "${share_backend_name}/netapp_port_name_search_pattern":      value => $netapp_port_name_search_pattern;
    "${share_backend_name}/netapp_trace_flags":                   value => $netapp_trace_flags;
  }

  package { 'nfs-utils': ensure => present }
}
