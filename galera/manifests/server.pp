# == Class: galera::server
#
# manages the installation of the galera server.
# manages the package, service, galera.cnf
#
# === Parameters:
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
#  [*wsrep_bind_address*]
#   Address to bind galera service.
#   Deprecated, please use ::mysql::server class.
#
#  [*mysql_server_hash*]
#   Hash of mysql server parameters.
#   Deprecated, please use ::mysql::server class.
#
#
#  [*manage_service*]
#   State of the service.
#   Deprecated, please use ::mysql::server class.
#
#  [*service_name*]
#   The name of the galera service.
#   Deprecated, please use ::mysql::server class.
#
#  [*service_enable*]
#   Defaults to true, boolean to set service enable.
#   Deprecated, please use ::mysql::server class.
#
#  [*service_ensure*]
#   Defaults to running, needed to set root password.
#   Deprecated, please use ::mysql::server class.
#
#  [*service_provider*]
#   What service provider to use.
#   Deprecated, please use ::mysql::server class.
#
# === Actions:
#
# === Requires:
#
# === Sample Usage:
# class { 'galera::server':
#   wsrep_cluster_name => 'galera_cluster',
#   wsrep_sst_method   => 'rsync'
#   wsrep_sst_username => 'ChangeMe',
#   wsrep_sst_password => 'ChangeMe',
# }
#
class galera::server (
  $bootstrap             = false,
  $debug                 = false,
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
  $create_mysql_resource = true,
  # DEPRECATED OPTIONS
  $mysql_server_hash     = {},
  $wsrep_bind_address    = '0.0.0.0',
  $manage_service        = false,
  $service_name          = 'mariadb',
  $service_enable        = true,
  $service_ensure        = 'running',
)  {
  if $create_mysql_resource {
  warning("DEPRECATED: ::mysql::server should be called manually, please set create_mysql_resource to false and call class ::mysql::server with your config")

    $mysql_server_class = { 'mysql::server' => $mysql_server_hash }

    create_resources( 'class', $mysql_server_class )
  }

  if $wsrep_bind_address {
    warning("DEPRECATED: wsrep_bind_address is deprecated, you should use bind_address of mysql module")
  }

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
    notify  => Service['mysqld'],
    require => Class['mysql::server::install'],
  }

  if $manage_service {
    warning("DEPRECATED: service setup is deprecated, you should use mysql module for this.")
    service { 'galera':
      ensure => $service_ensure,
      name   => $service_name,
      enable => $service_enable,
    }
  }
}
