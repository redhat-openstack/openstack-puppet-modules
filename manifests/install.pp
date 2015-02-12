# == Class opendaylight::install
#
# Manages the installation of OpenDaylight.
#
class opendaylight::install {
  if $opendaylight::install_method == 'rpm' {
    # Choose Yum URL based on OS (CentOS vs Fedora)
    $base_url = $::operatingsystem ? {
      'CentOS' => 'https://copr-be.cloud.fedoraproject.org/results/dfarrell07/OpenDaylight/epel-7-$basearch/',
      'Fedora' => 'https://copr-be.cloud.fedoraproject.org/results/dfarrell07/OpenDaylight/fedora-$releasever-$basearch/',
    }

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
  elsif $opendaylight::install_method == 'tarball' {
    # Download and extract the ODL tarball
    archive { 'opendaylight-0.2.2':
      ensure           => present,
      url              => $opendaylight::tarball_url,
      # Will end up installing in /opt/opendaylight-<version>
      target           => '/opt/',
      # Install will break if this is true and no chksum in expected path
      checksum         => false,
      # This discards top-level dir of extracted tarball
      # Required to get proper /opt/opendaylight-<version> path
      # Ideally, camptocamp/puppet-archive would support this. PR later?
      strip_components => 1,
    }

    # Download ODL systemd .service file and put in right location
    archive { 'opendaylight-systemd':
      ensure           => present,
      url              => $opendaylight::unitfile_url,
      target           => '/usr/lib/systemd/system/',
      # This prevents an opendaylight-systemd/ in the system/ dir
      root_dir         => '.',
      # Install will break if this is true and no chksum in expected path
      checksum         => false,
      # This discards top-level dir of extracted tarball
      # Required to get proper /opt/opendaylight-<version> path
      # Ideally, camptocamp/puppet-archive would support this. PR later?
      strip_components => 1,
    }
  }
  else {
    fail("Unknown install method: ${opendaylight::install_method}")
  }
}
