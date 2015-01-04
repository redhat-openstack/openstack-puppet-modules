# == Class: opendaylight
#
# Full description of class opendaylight here.
#
# === Parameters
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#
class opendaylight (
  $package_name = $::opendaylight::params::package_name,
  $service_name = $::opendaylight::params::service_name,
) inherits ::opendaylight::params {

  # validate parameters here

  class { '::opendaylight::install': } ->
  class { '::opendaylight::config': } ~>
  class { '::opendaylight::service': } ->
  Class['::opendaylight']
}
