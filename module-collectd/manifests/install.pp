class collectd::install (
  $version                 = $collectd::version,
  $package_name            = $collectd::package_name,
  $package_provider        = $collectd::package_provider,
  $package_install_options = $collectd::params::package_install_options,
  $manage_package          = $collectd::manage_package,
) {

  if $package_install_options != undef {
    validate_array($package_install_options)
  }

  if $manage_package {
    package { $package_name:
      ensure          => $version,
      name            => $package_name,
      provider        => $package_provider,
      install_options => $package_install_options,
    }
  }
}
