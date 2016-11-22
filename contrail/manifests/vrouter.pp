# == Class: contrail::vrouter
#
# Install and configure the vrouter service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for vrouter
#
class contrail::vrouter (
  $package_name = $contrail::params::vrouter_package_name,
) inherits contrail::params {

  anchor {'contrail::vrouter::start': } ->
  class {'::contrail::vrouter::install': } ->
  class {'::contrail::vrouter::config': } ~>
  class {'::contrail::vrouter::service': } ->
  class {'::contrail::vrouter::provision_vrouter': } ->
  class {'::contrail::qemu': }
  anchor {'contrail::vrouter::end': }
  
}
