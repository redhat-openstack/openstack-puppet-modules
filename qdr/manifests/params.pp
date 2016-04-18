#   Class: qdr::params
#
#   The Qpid Dispatch Router Module configuration settings
#
class qdr::params {

  $package_ensure       = 'installed'
  $service_package_name = 'qpid-dispatch-router'
  $service_name         = 'qdrouterd'
  $package_provider     = 'yum'
  $service_user         = 'qdrouterd'
  $service_group        = 'qdrouterd'
  $service_home         = '/var/lib/qdrouterd'
  $service_version      = '0.5.0'
  $sasl_package_list    = [ 'cyrus-sasl-lib', 'cyrus-sasl-plain' ]
  $tools_package_list   = [ 'qpid-dispatch-tools' ]

  if $::osfamily == 'Debian' {
      $service_package_name = 'qdrouterd'
      $package_provider     = 'apt'
      $sasl_package_list    = 'sasl2-bin'
      $tools_package_list   = [ 'qdmanage' , 'qdstat' ]
  }

  #service and config attributes
  $service_config_path     = '/etc/qpid-dispatch/qdrouterd.conf'
  $service_config_template = 'qdr/qdrouterd.conf.erb'
  $service_ensure          = running
  $service_enable          = true
  
  # container attributes
  $container_name           = "Qpid.Dispatch.Router.${::hostname}"
  $container_worker_threads = $::processorcount
  $container_debug_dump     = '/var/log/'
  $container_sasl_path      = '/etc/sasl2'
  $container_sasl_name      = 'qdrouterd'
    
  # router attributes
  $router_id                  = "Router.${::fqdn}"
  $router_mode                = 'standalone'
  $router_hello_interval      = '1'
  $router_hello_max_age       = '3'
  $router_ra_interval         = '30'
  $router_ra_interval_flux    = '4'
  $router_remote_ls_max_age   = '60'
  $router_mobile_addr_max_age = '60'

  # listener attributes
  $listener_addr            = '127.0.0.1'
  $listener_port            = '5672'
  $listener_ssl_cert_db     = '/etc/pki/tls/certs/amqp_cacert.crt'
  $listener_ssl_cert_file   = '/etc/pki/tls/certs/ssl_amqp.crt'
  $listener_ssl_key_file    = '/etc/pki/tls/private/ssl_amqp.key'
  $listener_ssl_pw_file     = undef
  $listener_ssl_password    = undef
  $listener_sasl_mech       = 'ANONYMOUS'
  $listener_auth_peer       = 'no'
  $listener_require_encrypt = 'no'
  $listener_require_ssl     = 'no'
  $listener_trusted_certs   = 'UNSET'
  $listener_max_frame_size  = '65536'
  $listener_idle_timout     = '16'
  
  # log parameters
  $log_module           = 'DEFAULT'
  $log_enable           = 'debug+'
  $log_output           = '/var/log/qdrouterd.log'

}
