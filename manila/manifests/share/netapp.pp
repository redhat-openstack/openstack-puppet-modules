# == Class: manila::share::netapp
#
# Configures Manila to use the NetApp share driver
#
# === Parameters
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
#  class { 'manila::share::netapp':
#    driver_handles_share_servers => true,
#    netapp_login                 => 'clusterAdmin',
#    netapp_password              => 'password',
#    netapp_server_hostname       => 'netapp.mycorp.com',
#    netapp_storage_family        => 'ontap_cluster',
#    netapp_transport_type        => 'https',
#  }
#

class manila::share::netapp (
    $driver_handles_share_servers,
    $netapp_login,
    $netapp_password,
    $netapp_server_hostname,
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

  manila::backend::netapp { 'DEFAULT':
    driver_handles_share_servers         => $driver_handles_share_servers,
    netapp_login                         => $netapp_login,
    netapp_password                      => $netapp_password,
    netapp_server_hostname               => $netapp_server_hostname,
    netapp_transport_type                => $netapp_transport_type,
    netapp_storage_family                => $netapp_storage_family,
    netapp_server_port                   => $netapp_server_port,
    netapp_volume_name_template          => $netapp_volume_name_template,
    netapp_vserver                       => $netapp_vserver,
    netapp_vserver_name_template         => $netapp_vserver_name_template,
    netapp_lif_name_template             => $netapp_lif_name_template,
    netapp_aggregate_name_search_pattern => $netapp_aggregate_name_search_pattern,
    netapp_root_volume_aggregate         => $netapp_root_volume_aggregate,
    netapp_root_volume_name              => $netapp_root_volume_name,
    netapp_port_name_search_pattern      => $netapp_port_name_search_pattern,
    netapp_trace_flags                   => $netapp_trace_flags,
  }
}
