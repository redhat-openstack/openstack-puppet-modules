# == Class: galera::server
#
# manages the installation of the galera server.
# manages the package, service, galera.cnf
#
# === Parameters:
#
#  [*mysql_server_hash*]
#   Hash of mysql server parameters.
#
#  [*bootstrap*]
#   Defaults to false, boolean to set cluster boostrap.
#
#  [*package_name*]
#   The name of the galera package.
#
#  [*package_ensure*]
#   Ensure state for package. Can be specified as version.
#
#  [*service_name*]
#   The name of the galera service.
#
#  [*service_enable*]
#   Defaults to true, boolean to set service enable.
#
#  [*service_ensure*]
#   Defaults to running, needed to set root password.
#
#  [*service_provider*]
#   What service provider to use.
#
#  [*wsrep_bind_address*]
#   Address to bind galera service.
#
#  [*wsrep_node_address*]
#   Address of local galera node.
#
#  [*wsrep_provider*]
#   Full path to wsrep provider library or 'none'.
#
#  [*wsrep_cluster_name*]
#   Logical cluster name.  be the same for all nodes.
#
#  [*wsrep_cluster_members*]
#   List of cluster members, IP addresses or hostnames.
#
#  [*wsrep_sst_method*]
#   State snapshot transfer method.
#
#  [*wsrep_sst_username*]
#   Username used by the wsrep_sst_auth authentication string.
#
#  [*wsrep_sst_password*]
#   Password used by the wsrep_sst_auth authentication string.
#
#  [*wsrep_ssl*]
#   Boolean to disable SSL even if certificate and key are configured.
#
#  [*wsrep_ssl_key*]
#   Private key for the certificate above, unencrypted, in PEM format.
#
#  [*wsrep_ssl_cert*]
#   Certificate file in PEM format.
#
#  [*debug*]
#
#  [*manage_service*]
#   State of the service.
#
# === Actions:
#
# === Requires:
#
# === Sample Usage:
# class { 'galera::server':
#   config_hash => {
#     bind_address   => '0.0.0.0',
#     default_engine => 'InnoDB',
#     root_password  => 'root_pass',
#   },
#   wsrep_cluster_name => 'galera_cluster',
#   wsrep_sst_method   => 'rsync'
#   wsrep_sst_username => 'ChangeMe',
#   wsrep_sst_password => 'ChangeMe',
# }
#
class galera::server (
  $mysql_server_hash     = {},
  $bootstrap             = false,
  $debug                 = false,
  $service_name          = 'mariadb',
  $service_enable        = true,
  $service_ensure        = 'running',
  $manage_service        = false,
  $wsrep_bind_address    = '0.0.0.0',
  $wsrep_node_address    = undef,
  $wsrep_provider        = '/usr/lib64/galera/libgalera_smm.so',
  $wsrep_cluster_name    = 'galera_cluster',
  $wsrep_cluster_members = [ $::ipaddress ],
  $wsrep_sst_method      = 'rsync',
  $wsrep_sst_username    = 'root',
  $wsrep_sst_password    = undef,
  $wsrep_ssl             = false,
  $wsrep_ssl_key         = undef,
  $wsrep_ssl_cert        = undef,
)  {

  $mysql_server_class = { 'mysql::server' => $mysql_server_hash }

  create_resources( 'class', $mysql_server_class )

  $wsrep_provider_options = wsrep_options({
    'socket.ssl'      => $wsrep_ssl,
    'socket.ssl_key'  => $wsrep_ssl_key,
    'socket.ssl_cert' => $wsrep_ssl_cert,
  })

  $wsrep_debug = bool2num($debug)

  file { '/etc/my.cnf.d/galera.cnf':
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('galera/wsrep.cnf.erb'),
    notify  => Service[$service_name],
  }

  if $manage_service {
    service { 'galera':
      ensure => $service_ensure,
      name   => $service_name,
      enable => $service_enable,
    }
  }
}
