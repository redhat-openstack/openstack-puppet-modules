# == Class: opendaylight
#
# OpenDaylight SDN Controller
#
# === Parameters
# TODO: Update these param docs
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#
class opendaylight (
  $default_features = $::opendaylight::params::default_features,
  $extra_features = $::opendaylight::params::extra_features,
) inherits ::opendaylight::params {

  # Validate OS family
  if $::osfamily != 'RedHat' {
    fail("Unsupported OS family: ${::osfamily}")
  }

  # Validate OS
  case $::operatingsystem {
    centos, redhat: {
      if $::operatingsystemmajrelease != 7 {
        # RHEL/CentOS versions < 7 not supported as they lack systemd
        fail("Unsupported OS: ${::operatingsystem} ${::operatingsystemmajrelease}")
      }
    }
    fedora: {
      # Fedora distros < 20 are EOL as of Jan 6th 2015
      if ! ($::operatingsystemmajrelease in [20, 21]) {
        fail("Unsupported OS: ${::operatingsystem} ${::operatingsystemmajrelease}")
      }
    }
    default: {
      fail("Unsupported OS: ${::operatingsystem}")
    }
  }

  # Build full list of features to install
  $features = union($default_features, $extra_features)

  class { '::opendaylight::install': } ->
  class { '::opendaylight::config': } ~>
  class { '::opendaylight::service': } ->
  Class['::opendaylight']
}
