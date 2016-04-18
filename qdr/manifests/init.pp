# Class: qdr
# ===========================
#
# Full description of class qdr here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'qdr':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Author Name <author@domain.com>
#
# Copyright
# ---------
#
# Copyright 2016 Your name here, unless otherwise noted.
#
class qdr(
  $container_debug_dump       = $qdr::params::container_debug_dump,
  $container_name             = $qdr::params::container_name,
  $container_worker_threads   = $qdr::params::container_worker_threads,
  $container_sasl_name        = $qdr::params::container_sasl_name,
  $container_sasl_path        = $qdr::params::container_sasl_path,
  $listener_addr              = $qdr::params::listener_addr,
  $listener_auth_peer         = $qdr::params::listener_auth_peer,
  $listener_idle_timeout      = $qdr::params::listener_idle_timeout,
  $listener_max_frame_size    = $qdr::params::listener_max_frame_size,
  $listener_port              = $qdr::params::listener_port,
  $listener_require_encrypt   = $qdr::params::listener_require_encrypt,
  $listener_require_ssl       = $qdr::params::listener_require_ssl,
  $listener_sasl_mech         = $qdr::params::listener_sasl_mech,
  $listener_ssl_cert_db       = $qdr::params::listener_ssl_cert_db,
  $listener_ssl_cert_file     = $qdr::params::listener_ssl_cert_file,
  $listener_ssl_key_file      = $qdr::params::listener_ssl_key_file,
  $listener_ssl_password      = $qdr::params::listener_ssl_password,
  $listener_ssl_pw_file       = $qdr::params::listener_ssl_pw_file,
  $listener_trusted_certs     = $qdr::params::listener_trusted_certs,
  $log_enable                 = $qdr::params::log_enable,
  $log_module                 = $qdr::params::log_module,
  $log_output                 = $qdr::params::log_output,
  $package_ensure             = $qdr::params::package_ensure,
  $package_provider           = $qdr::params::package_provider,
  $router_hello_interval      = $qdr::params::router_hello_interval,
  $router_hello_max_age       = $qdr::params::router_hello_max_age,
  $router_id                  = $qdr::params::router_id,
  $router_mobile_addr_max_age = $qdr::params::router_mobile_addr_max_age,
  $router_mode                = $qdr::params::router_mode,
  $router_ra_interval         = $qdr::params::router_ra_interval,
  $router_ra_interval_flux    = $qdr::params::router_ra_interval_flux,
  $sasl_package_list          = $qdr::params::sasl_package_list,
  $service_config_path        = $qdr::params::service_config_path,
  $service_config_template    = $qdr::params::service_config_template,
  $service_enable             = $qdr::params::service_enable,
  $service_ensure             = $qdr::params::service_ensure,
  $service_group              = $qdr::params::service_group,
  $service_home               = $qdr::params::service_home,
  $service_package_name       = $qdr::params::service_package_name,
  $service_user               = $qdr::params::service_user,
  $service_name               = $qdr::params::service_name,
  $service_version            = $qdr::params::service_version,
  $tools_package_list         = $qdr::params::tools_package_list,
  
  
) inherits qdr::params {

  validate_string($container_name)
  validate_string($container_worker_threads) 
  validate_absolute_path($container_debug_dump)
  validate_absolute_path($container_sasl_path)
  validate_string($container_sasl_name)  
  validate_re($router_mode,'^(standalone$|interior$)')
  validate_string($router_id)
  validate_string($listener_addr)
  validate_re($listener_port, '\d+')
  validate_re($listener_auth_peer,'^(yes$|no$)')
  validate_string($listener_sasl_mech)
  
  class { '::qdr::install': } ->
  class { '::qdr::config': } ~>
  class { '::qdr::service': }

}
