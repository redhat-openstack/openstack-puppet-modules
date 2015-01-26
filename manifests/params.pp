# == Class opendaylight::params
#
# This class is meant to be called from opendaylight.
# It sets variables according to platform.
#
class opendaylight::params {
  $features = ['config', 'standard', 'region', 'package', 'kar', 'ssh', 'management']
}
