# == Class opendaylight::install
#
# This class is called from opendaylight for install.
#
class opendaylight::install {
  $base_url = $::operatingsystem ? {
    'CentOS' => 'https://copr-be.cloud.fedoraproject.org/results/dfarrell07/OpenDaylight/epel-7-$basearch/',
    'Fedora' => 'https://copr-be.cloud.fedoraproject.org/results/dfarrell07/OpenDaylight/fedora-$releasever-$basearch/',
  }

  if $::tarball_url == '' {
    yumrepo { 'opendaylight':
      # 'ensure' isn't supported with Puppet <3.5
      # Seems to default to present, but docs don't say
      # https://docs.puppetlabs.com/references/3.4.0/type.html#yumrepo
      # https://docs.puppetlabs.com/references/3.5.0/type.html#yumrepo
      baseurl  => $base_url,
      descr    => 'OpenDaylight SDN controller',
      gpgcheck => 0,
      enabled  => 1,
      before   => Package['opendaylight'],
    }

    package { 'opendaylight':
      ensure  => present,
      require => Yumrepo['opendaylight'],
    }
  }
  else {
    archive { 'opendaylight-0.2.2':
      ensure           => present,
      # TODO: Removed hard-coded URL, use param
      url              => 'https://nexus.opendaylight.org/content/groups/public/org/opendaylight/integration/distribution-karaf/0.2.2-Helium-SR2/distribution-karaf-0.2.2-Helium-SR2.tar.gz',
      target           => '/opt/',
      checksum         => false,
      # This discards top-level dir of extracted tarball
      # Required to get proper /opt/opendaylight-<version> path
      # Ideally, camptocamp/puppet-archive would support this. PR later?
      strip_components => 1,
    }
    # TODO: Download ODL systemd .service file and put in right location
  }
}
