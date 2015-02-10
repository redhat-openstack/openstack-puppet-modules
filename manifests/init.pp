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
  $install_method = $::opendaylight::params::install_method,
  $tarball_url = $::opendaylight::params::tarball_url,
  $unitfile_url = $::opendaylight::params::unitfile_url,
) inherits ::opendaylight::params {

  # NB: This is a work-around for a bug in gini/puppet-archive
  # See: https://github.com/bfraser/puppet-grafana/issues/5#issuecomment-59269431
  include archive::prerequisites

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
