class fluentd (
  $repo_install = $fluentd::repo_install,
  $repo_name = $fluentd::repo_name,
  $repo_desc = $fluentd::repo_desc,
  $repo_url = $fluentd::repo_url,
  $repo_enabled = $fluentd::repo_enabled,
  $repo_gpgcheck = $fluentd::repo_gpgcheck,
  $repo_gpgkey = $fluentd::repo_gpgkey,
  $repo_gpgkeyid = $fluentd::repo_gpgkeyid,
  $package_name = $fluentd::package_name,
  $package_ensure = $fluentd::package_ensure,
  $plugin_names = $fluentd::plugin_names,
  $plugin_ensure = $fluentd::plugin_ensure,
  $plugin_source = $fluentd::plugin_source,
  $service_name = $fluentd::service_name,
  $service_ensure = $fluentd::service_ensure,
  $service_enable = $fluentd::service_enable,
  $service_manage = $fluentd::service_manage,
  $config_file = $fluentd::config_file,
) inherits fluentd::params {

  # Param validations
  validate_bool($repo_install)
  validate_string($repo_name)
  validate_string($repo_url)
  validate_bool($repo_enabled)
  validate_bool($repo_gpgcheck)
  validate_string($repo_gpgkey)
  validate_string($repo_gpgkeyid)
  validate_string($package_name)
  validate_string($package_ensure)
  validate_array($plugin_names)
  validate_string($plugin_ensure)
  validate_string($plugin_source)
  validate_string($service_name)
  validate_string($service_ensure)
  validate_bool($service_enable)
  validate_bool($service_manage)
  validate_absolute_path($config_file)

  contain fluentd::install
  contain fluentd::service

  Class['Fluentd::Install'] ->
  Class['Fluentd::Service']
}
