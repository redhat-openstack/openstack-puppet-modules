# == Class opendaylight::install
#
# This class is called from opendaylight for install.
#
class opendaylight::install {
  $base_url = $::operatingsystem ? {
    'CentOS' => 'https://copr-be.cloud.fedoraproject.org/results/dfarrell07/OpenDaylight/epel-7-$basearch/',
    'Fedora' => 'https://copr-be.cloud.fedoraproject.org/results/dfarrell07/OpenDaylight/fedora-$releasever-$basearch/',
  }

  yumrepo { 'opendaylight':
    # 'ensure' isn't supported with Puppet <3.5
    # hopfully it defaults to present, but docs don't say
    # https://docs.puppetlabs.com/references/3.4.0/type.html#yumrepo
    # https://docs.puppetlabs.com/references/3.5.0/type.html#yumrepo
    #ensure  => 'present',
    baseurl  => $base_url,
    descr    => 'OpenDaylight SDN controller',
    gpgcheck => 0,
    enabled  => 1,
    before   => Package['opendaylight'],
  }

  package { $::opendaylight::package_name:
    ensure  => present,
    require => Yumrepo['opendaylight'],
  }
}
