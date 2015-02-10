# == Class opendaylight::params
#
# This class is meant to be called from opendaylight.
# It sets variables according to platform.
#
class opendaylight::params {
  $default_features = ['config', 'standard', 'region', 'package', 'kar', 'ssh', 'management']
  $extra_features = []
  # TODO: Consider making an install_method param that defaults to 'rpm'
  $tarball_url = ''
}
