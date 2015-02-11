# == Class opendaylight::params
#
# This class is meant to be called from opendaylight.
# It sets variables according to platform.
#
class opendaylight::params {
  $default_features = ['config', 'standard', 'region', 'package', 'kar', 'ssh', 'management']
  $extra_features = []
  $odl_rest_port = '8080'
  $install_method = 'rpm'
  $tarball_url = 'https://nexus.opendaylight.org/content/groups/public/org/opendaylight/integration/distribution-karaf/0.2.2-Helium-SR2/distribution-karaf-0.2.2-Helium-SR2.tar.gz'
  $unitfile_url = 'https://github.com/dfarrell07/opendaylight-systemd/archive/master/opendaylight-unitfile.tar.gz'
}
