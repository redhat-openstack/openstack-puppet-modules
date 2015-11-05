# == Class: contrail::control
#
# Install and configure the control service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for control
#
class contrail::control (
  $package_name = $contrail::params::control_package_name,
) inherits contrail::params {

  anchor {'contrail::control::start': } ->
  class {'::contrail::control::install': } ->
  class {'::contrail::control::config': } ~>
  class {'::contrail::control::service': }
  anchor {'contrail::control::end': }
  
}
