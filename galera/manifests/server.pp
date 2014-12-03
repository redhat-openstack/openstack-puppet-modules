# Class: galera::server
#
# manages the installation of the galera server.
# manages the package, service, galera.cnf
#
# Parameters:
#  [*config_hash*]           - Hash of config parameters that need to be set.
#  [*bootstrap*]             - Defaults to false, boolean to set cluster boostrap.
#  [*package_name*]          - The name of the galera package.
#  [*package_ensure*]        - Ensure state for package. Can be specified as version.
#  [*service_name*]          - The name of the galera service.
#  [*service_enable*]        - Defaults to true, boolean to set service enable.
#  [*service_ensure*]        - Defaults to running, needed to set root password.
#  [*service_provider*]      - What service provider to use.
#  [*wsrep_bind_address*]    - Address to bind galera service.
#  [*wsrep_provider*]        - Full path to wsrep provider library or 'none'.
#  [*wsrep_cluster_name*]    - Logical cluster name. Should be the same for all nodes.
#  [*wsrep_cluster_members*] - List of cluster members, IP addresses or hostnames.
#  [*wsrep_sst_method*]      - State snapshot transfer method.
#  [*wsrep_sst_username*]    - Username used by the wsrep_sst_auth authentication string.
#  [*wsrep_sst_password*]    - Password used by the wsrep_sst_auth authentication string.
#  [*wsrep_ssl*]             - Boolean to disable SSL even if certificate and key are configured.
#  [*wsrep_ssl_key*]         - Private key for the certificate above, unencrypted, in PEM format.
#  [*wsrep_ssl_cert*]        - Certificate file in PEM format.
#
# Actions:
#
# Requires:
#
# Sample Usage:
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
  $config_hash           = {},
  $bootstrap             = false,
  $debug                 = false,
  $package_name          = 'mariadb-galera-server',
  $package_ensure        = 'present',
  $service_name          = $mysql::params::service_name,
  $service_enable        = true,
  $service_ensure        = 'running',
  $service_provider      = $mysql::params::service_provider,
  $wsrep_bind_address    = '0.0.0.0',
  $wsrep_provider        = '/usr/lib64/galera/libgalera_smm.so',
  $wsrep_cluster_name    = 'galera_cluster',
  $wsrep_cluster_members = [ $::ipaddress ],
  $wsrep_sst_method      = 'rsync',
  $wsrep_sst_username    = 'root',
  $wsrep_sst_password    = undef,
  $wsrep_ssl             = false,
  $wsrep_ssl_key         = undef,
  $wsrep_ssl_cert        = undef,
) inherits mysql {

  $config_class = { 'mysql::config' => $config_hash }

  create_resources( 'class', $config_class )

  package { 'galera':
    name   => $package_name,
    ensure => $package_ensure,
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
    notify  => Service['galera'],
  }

  Service['galera'] -> Exec<| title == 'set_mysql_rootpw' |>

  service { 'galera':
    name     => $service_name,
    enable   => $service_enable,
    ensure   => $service_ensure,
    require  => Package['galera'],
    provider => $service_provider,
  }
}
