# == Class: opendaylight
#
# OpenDaylight SDN Controller
#
# === Parameters
# [*default_features*]
#   Features that should normally be installed by default, but can be overridden.
# [*extra_features*]
#   List of features to install in addition to the default ones.
# [*odl_rest_port *]
#   Port for ODL northbound REST interface to listen on.
# [*install_method *]
#   How to install OpenDaylight. Current options are "rpm" and "tarball", default is RPM.
# [*tarball_url*]
#   If installing from a tarball, use this one. Defaults to latest ODL.
# [*unitfile_url*]
#   OpenDaylight .service file to use for tarball installs. Defaults to one used by ODL RPM.
#
class opendaylight (
  $default_features = $::opendaylight::params::default_features,
  $extra_features = $::opendaylight::params::extra_features,
  $odl_rest_port = $::opendaylight::params::odl_rest_port,
  $install_method = $::opendaylight::params::install_method,
  $tarball_url = $::opendaylight::params::tarball_url,
  $unitfile_url = $::opendaylight::params::unitfile_url,
) inherits ::opendaylight::params {

  # Validate OS family
  case $::osfamily {
    Debian: {
        warning('Debian family is valid but only installable with tarball method')
    }
    RedHat: {}
    default: {
        fail("Unsupported OS family: ${::osfamily}")
    }
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
    Ubuntu: {
      if $::operatingsystemmajrelease != '14.04' {
        # Only tested on 14.04
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
  class { '::opendaylight::config': odl_rest_port => $odl_rest_port} ~>
  class { '::opendaylight::service': } ->
  Class['::opendaylight']
}
