# == Class zookeeper
#
# === Parameters
#
# TODO: Document each class parameter.
#
# [*config_map*]
#   Use this parameter for all other ZooKeeper related config options except those that are already exposed as class
#   parameters (e.g. `$data_dir`, `$data_log_dir`, `$client_port`, `$myid`, `$quorum`).
#
class zookeeper (
  $client_port            = $zookeeper::params::client_port,
  $command                = $zookeeper::params::command,
  $config                 = $zookeeper::params::config,
  $config_map             = $zookeeper::params::config_map,
  $config_template        = $zookeeper::params::config_template,
  $data_dir               = $zookeeper::params::data_dir,
  $data_log_dir           = $zookeeper::params::data_log_dir,
  $group                  = $zookeeper::params::group,
  $myid                   = $zookeeper::params::myid,
  $package_name           = $zookeeper::params::package_name,
  $package_ensure         = $zookeeper::params::package_ensure,
  $quorum                 = $zookeeper::params::quorum,
  $service_autorestart    = hiera('zookeeper::service_autorestart', $zookeeper::params::service_autorestart),
  $service_enable         = hiera('zookeeper::service_enable', $zookeeper::params::service_enable),
  $service_ensure         = $zookeeper::params::service_ensure,
  $service_manage         = hiera('zookeeper::service_manage', $zookeeper::params::service_manage),
  $service_name           = $zookeeper::params::service_name,
  $service_retries        = $zookeeper::params::service_retries,
  $service_startsecs      = $zookeeper::params::service_startsecs,
  $service_stderr_logfile_keep    = $zookeeper::params::service_stderr_logfile_keep,
  $service_stderr_logfile_maxsize = $zookeeper::params::service_stderr_logfile_maxsize,
  $service_stdout_logfile_keep    = $zookeeper::params::service_stdout_logfile_keep,
  $service_stdout_logfile_maxsize = $zookeeper::params::service_stdout_logfile_maxsize,
  $service_stopasgroup    = hiera('zookeeper::service_stopasgroup', $zookeeper::params::service_stopasgroup),
  $service_stopsignal     = $zookeeper::params::service_stopsignal,
  $user                   = $zookeeper::params::user,
  $zookeeper_start_binary = $zookeeper::params::zookeeper_start_binary,
) inherits zookeeper::params {

  if !is_integer($client_port) { fail('The $client_port parameter must be an integer number') }
  validate_string($command)
  validate_absolute_path($config)
  validate_hash($config_map)
  validate_string($config_template)
  validate_absolute_path($data_dir)
  validate_absolute_path($data_log_dir)
  validate_string($group)
  if !is_integer($myid) { fail('The $myid parameter must be an integer number') }
  validate_string($package_name)
  validate_string($package_ensure)
  validate_array($quorum)
  validate_bool($service_autorestart)
  validate_bool($service_enable)
  validate_string($service_ensure)
  validate_bool($service_manage)
  validate_string($service_name)
  if !is_integer($service_retries) { fail('The $service_retries parameter must be an integer number') }
  if !is_integer($service_startsecs) { fail('The $service_startsecs parameter must be an integer number') }
  if !is_integer($service_stderr_logfile_keep) {
    fail('The $service_stderr_logfile_keep parameter must be an integer number')
  }
  validate_string($service_stderr_logfile_maxsize)
  if !is_integer($service_stdout_logfile_keep) {
    fail('The $service_stdout_logfile_keep parameter must be an integer number')
  }
  validate_string($service_stdout_logfile_maxsize)
  validate_bool($service_stopasgroup)
  validate_string($service_stopsignal)
  validate_string($user)
  validate_absolute_path($zookeeper_start_binary)

  $is_standalone = empty($quorum)

  include '::zookeeper::install'
  include '::zookeeper::config'
  include '::zookeeper::service'

  # Anchor this as per #8040 - this ensures that classes won't float off and
  # mess everything up. You can read about this at:
  # http://docs.puppetlabs.com/puppet/2.7/reference/lang_containment.html#known-issues
  anchor { 'zookeeper::begin': }
  anchor { 'zookeeper::end': }

  Anchor['zookeeper::begin'] -> Class['::zookeeper::install'] -> Class['::zookeeper::config']
    ~> Class['::zookeeper::service'] -> Anchor['zookeeper::end']
}
