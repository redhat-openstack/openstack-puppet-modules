require 'puppetlabs_spec_helper/module_spec_helper'

# Customize filters to ignore 3rd-party code
# If the coverage report shows not-our-code results, add it here
custom_filters = [
  'Anchor[java::end]',
  'Stage[setup]',
  'Anchor[java::begin:]',
  'Archive::Download[opendaylight.tar.gz]',
  'Archive::Download[opendaylight-systemd.tar.gz]',
  'Archive::Extract[opendaylight]',
  'Archive::Extract[opendaylight-systemd]',
  'Class[Java::Config]',
  'Class[Java::Params]',
  'Class[Stdlib::Stages]',
  'Class[Stdlib]',
  'Exec[download archive opendaylight.tar.gz and check sum]',
  'Exec[download archive opendaylight-systemd.tar.gz and check sum]',
  'Exec[opendaylight unpack]',
  'Exec[opendaylight-systemd unpack]',
  'Exec[rm-on-error-opendaylight.tar.gz]',
  'Exec[rm-on-error-opendaylight-systemd.tar.gz]',
  'Exec[update-java-alternatives]',
  'Package[curl]',
  'Stage[deploy]',
  'Stage[deploy_app]',
  'Stage[deploy_infra]',
  'Stage[runtime]',
  'Stage[setup_app]',
  'Stage[setup_infra]',
]
RSpec::Puppet::Coverage.filters.push(*custom_filters)

#
# NB: This is a library of helper fns used by the rspec-puppet tests
#

# Tests that are common to all possible configurations
def generic_tests()
  # Confirm that module compiles
  it { should compile }
  it { should compile.with_all_deps }

  # Confirm presence of classes
  it { should contain_class('opendaylight') }
  it { should contain_class('opendaylight::params') }
  it { should contain_class('opendaylight::install') }
  it { should contain_class('opendaylight::config') }
  it { should contain_class('opendaylight::service') }

  # Confirm relationships between classes
  it { should contain_class('opendaylight::install').that_comes_before('opendaylight::config') }
  it { should contain_class('opendaylight::config').that_requires('opendaylight::install') }
  it { should contain_class('opendaylight::config').that_notifies('opendaylight::service') }
  it { should contain_class('opendaylight::service').that_subscribes_to('opendaylight::config') }
  it { should contain_class('opendaylight::service').that_comes_before('opendaylight') }
  it { should contain_class('opendaylight').that_requires('opendaylight::service') }

  # Confirm presence of generic resources
  it { should contain_service('opendaylight') }
  it { should contain_file('org.apache.karaf.features.cfg') }

  # Confirm properties of generic resources
  # NB: These hashes don't work with Ruby 1.8.7, but we
  #   don't support 1.8.7 so that's okay. See issue #36.
  it {
    should contain_service('opendaylight').with(
      'ensure'      => 'running',
      'enable'      => 'true',
      'hasstatus'   => 'true',
      'hasrestart'  => 'true',
    )
  }
  it {
    should contain_file('org.apache.karaf.features.cfg').with(
      'ensure'      => 'file',
      'path'        => '/opt/opendaylight/etc/org.apache.karaf.features.cfg',
      'owner'   => 'odl',
      'group'   => 'odl',
    )
  }
end

# Shared tests that specialize in testing Karaf feature installs
def karaf_feature_tests(options = {})
  # Extract params
  # NB: This default list should be the same as the one in opendaylight::params
  # TODO: Remove this possible source of bugs^^
  default_features = options.fetch(:default_features, ['config', 'standard', 'region', 'package', 'kar', 'ssh', 'management'])
  extra_features = options.fetch(:extra_features, [])

  # The order of this list concat matters
  features = default_features + extra_features
  features_csv = features.join(',')

  # Confirm properties of Karaf features config file
  # NB: These hashes don't work with Ruby 1.8.7, but we
  #   don't support 1.8.7 so that's okay. See issue #36.
  it {
    should contain_file('org.apache.karaf.features.cfg').with(
      'ensure'      => 'file',
      'path'        => '/opt/opendaylight/etc/org.apache.karaf.features.cfg',
      'owner'   => 'odl',
      'group'   => 'odl',
    )
  }
  it {
    should contain_file_line('featuresBoot').with(
      'path'  => '/opt/opendaylight/etc/org.apache.karaf.features.cfg',
      'line'  => "featuresBoot=#{features_csv}",
      'match' => '^featuresBoot=.*$',
    )
  }
end

# Shared tests that specialize in testing ODL's REST port config
def odl_rest_port_tests(options = {})
  # Extract params
  # NB: This default value should be the same as one in opendaylight::params
  # TODO: Remove this possible source of bugs^^
  odl_rest_port = options.fetch(:odl_rest_port, 8080)

  # Confirm properties of ODL REST port config file
  # NB: These hashes don't work with Ruby 1.8.7, but we
  #   don't support 1.8.7 so that's okay. See issue #36.
  it {
    should contain_file('jetty.xml').with(
      'ensure'      => 'file',
      'path'        => '/opt/opendaylight/etc/jetty.xml',
      'owner'   => 'odl',
      'group'   => 'odl',
      'content'     => /Property name="jetty.port" default="#{odl_rest_port}"/
    )
  }
end

def log_level_tests(options = {})
  # Extract params
  # NB: This default value should be the same as one in opendaylight::params
  # TODO: Remove this possible source of bugs^^
  log_levels = options.fetch(:log_levels, {})

  if log_levels.empty?
    # Should contain log level config file
    it {
      should contain_file('org.ops4j.pax.logging.cfg').with(
        'ensure'      => 'file',
        'path'        => '/opt/opendaylight/etc/org.ops4j.pax.logging.cfg',
        'owner'   => 'odl',
        'group'   => 'odl',
      )
    }
    # Should not contain custom log level config
    it {
      should_not contain_file('org.ops4j.pax.logging.cfg').with(
        'ensure'      => 'file',
        'path'        => '/opt/opendaylight/etc/org.ops4j.pax.logging.cfg',
        'owner'   => 'odl',
        'group'   => 'odl',
        'content'     => /# Log level config added by puppet-opendaylight/
      )
    }
  else
    # Should contain log level config file
    it {
      should contain_file('org.ops4j.pax.logging.cfg').with(
        'ensure'      => 'file',
        'path'        => '/opt/opendaylight/etc/org.ops4j.pax.logging.cfg',
        'owner'   => 'odl',
        'group'   => 'odl',
      )
    }
    # Should contain custom log level config
    it {
      should contain_file('org.ops4j.pax.logging.cfg').with(
        'ensure'      => 'file',
        'path'        => '/opt/opendaylight/etc/org.ops4j.pax.logging.cfg',
        'owner'   => 'odl',
        'group'   => 'odl',
        'content'     => /# Log level config added by puppet-opendaylight/
      )
    }
    # Verify each custom log level config entry
    log_levels.each_pair do |logger, level|
      it {
        should contain_file('org.ops4j.pax.logging.cfg').with(
          'ensure'      => 'file',
          'path'        => '/opt/opendaylight/etc/org.ops4j.pax.logging.cfg',
          'owner'   => 'odl',
          'group'   => 'odl',
          'content'     => /^log4j.logger.#{logger} = #{level}/
        )
      }
    end
  end
end

# Shared tests that specialize in testing enabling L3 via ODL OVSDB
def enable_l3_tests(options = {})
  # Extract params
  # NB: This default value should be the same as one in opendaylight::params
  # TODO: Remove this possible source of bugs^^
  enable_l3 = options.fetch(:enable_l3, 'no')

  if [true, 'yes'].include? enable_l3
    # Confirm ODL OVSDB L3 is enabled
    it {
      should contain_file('custom.properties').with(
        'ensure'      => 'file',
        'path'        => '/opt/opendaylight/etc/custom.properties',
        'owner'   => 'odl',
        'group'   => 'odl',
        'content'     => /^ovsdb.l3.fwd.enabled=yes/
      )
    }
  elsif [false, 'no'].include? enable_l3
    # Confirm ODL OVSDB L3 is disabled
    it {
      should contain_file('custom.properties').with(
        'ensure'      => 'file',
        'path'        => '/opt/opendaylight/etc/custom.properties',
        'owner'   => 'odl',
        'group'   => 'odl',
        'content'     => /^ovsdb.l3.fwd.enabled=no/
      )
    }
  end
end

def tarball_install_tests(options = {})
  # Extract params
  # NB: These default values should be the same as ones in opendaylight::params
  # TODO: Remove this possible source of bugs^^
  tarball_url = options.fetch(:tarball_url, 'https://nexus.opendaylight.org/content/repositories/staging/org/opendaylight/integration/distribution-karaf/0.4.0-Beryllium-RC1/distribution-karaf-0.4.0-Beryllium-RC1.tar.gz')
  unitfile_url = options.fetch(:unitfile_url, 'https://github.com/dfarrell07/opendaylight-systemd/archive/master/opendaylight-unitfile.tar.gz')
  osfamily = options.fetch(:osfamily, 'RedHat')

  # Confirm presence of tarball-related resources
  it { should contain_archive('opendaylight') }
  it { should contain_class('java') }
  it { should contain_file('/opt/opendaylight/') }
  it { should contain_user('odl') }
  it { should contain_group('odl') }

  # Confirm relationships between tarball-related resources
  it { should contain_archive('opendaylight').that_comes_before('File[/opt/opendaylight/]') }
  it { should contain_archive('opendaylight').that_comes_before('User[odl]') }
  it { should contain_file('/opt/opendaylight/').that_requires('Archive[opendaylight]') }
  it { should contain_file('/opt/opendaylight/').that_requires('Group[odl]') }
  it { should contain_file('/opt/opendaylight/').that_requires('User[odl]') }
  it { should contain_user('odl').that_comes_before('File[/opt/opendaylight/]') }
  it { should contain_user('odl').that_requires('Archive[opendaylight]') }
  it { should contain_user('odl').that_requires('Group[odl]') }
  it { should contain_group('odl').that_comes_before('File[/opt/opendaylight/]') }
  it { should contain_group('odl').that_comes_before('User[odl]') }

  # Confirm properties of tarball-related resources
  # NB: These hashes don't work with Ruby 1.8.7, but we
  #   don't support 1.8.7 so that's okay. See issue #36.
  it {
    should contain_archive('opendaylight').with(
      'ensure'           => 'present',
      'url'              => tarball_url,
      'target'           => '/opt/opendaylight/',
      'checksum'         => false,
      'strip_components' => 1,
      'timeout'          => 600,
    )
  }
  it {
    should contain_file('/opt/opendaylight/').with(
      'ensure'  => 'directory',
      'recurse' => true,
      'owner'   => 'odl',
      'group'   => 'odl',
    )
  }
  it {
    should contain_user('odl').with(
      'name'       => 'odl',
      'ensure'     => 'present',
      'home'       => '/opt/opendaylight/',
      'membership' => 'minimum',
      'groups'     => 'odl',
    )
  }
  it {
    should contain_group('odl').with(
      'name'       => 'odl',
      'ensure'     => 'present',
    )
  }

  # OS-specific validations
  case osfamily
  when 'RedHat'
    # Validations specific to Red Hat family OSs (RHEL/CentOS/Fedora)
    it { should contain_archive('opendaylight-systemd') }
    it { should contain_file('/usr/lib/systemd/system/opendaylight.service') }
    it { should contain_archive('opendaylight-systemd').that_comes_before('File[/usr/lib/systemd/system/opendaylight.service]') }
    it { should contain_file('/usr/lib/systemd/system/opendaylight.service').that_requires('Archive[opendaylight-systemd]') }

    # NB: These hashes don't work with Ruby 1.8.7, but we
    #   don't support 1.8.7 so that's okay. See issue #36.
    it {
      should contain_package('java').with(
        'name' => 'java-1.7.0-openjdk',
      )
    }
    it {
      should contain_archive('opendaylight-systemd').with(
        'ensure'           => 'present',
        'url'              => unitfile_url,
        'target'           => '/usr/lib/systemd/system/',
        'root_dir'         => 'opendaylight.service',
        'checksum'         => false,
        'strip_components' => 1,
        'follow_redirects' => true,
      )
    }
    it {
      should contain_file('/usr/lib/systemd/system/opendaylight.service').with(
        'ensure'  => 'file',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
      )
    }
  when 'Debian'
    # Validations specific to Debain family OSs (Ubuntu)
    it {
      should contain_package('java').with(
        'name' => 'openjdk-7-jdk',
      )
    }
    it {
      should contain_file('/etc/init/opendaylight.conf').with(
        'ensure'  => 'file',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
      )
    }
    expected_msg = 'Debian has limited support, is less stable, less tested.'
    it {
      expect {
        # This could be any check, most (all?) will raise warning
        should contain_file('/etc/init/opendaylight.conf').to(
          raise_warning(Puppet::Warning, /#{expected_msg}/)
        )
      }
    }
  else
    fail("Unexpected osfamily #{osfamily}")
  end

  # Verify that there are no unexpected resources from RPM-type installs
  it { should_not contain_yumrepo('opendaylight-4-testing') }
  it { should_not contain_package('opendaylight') }
end

def rpm_install_tests(options = {})
  # Extract params
  # Choose Yum URL based on OS (CentOS vs Fedora)
  # NB: Currently using the CentOS CBS for both Fedora and CentOS
  operatingsystem  = options.fetch(:operatingsystem, 'CentOS')
  case operatingsystem
  when 'CentOS'
    yum_repo = 'http://cbs.centos.org/repos/nfv7-opendaylight-4-testing/$basearch/os/'
  when 'Fedora'
    yum_repo = 'http://cbs.centos.org/repos/nfv7-opendaylight-4-testing/$basearch/os/'
  else
    fail("Unknown operatingsystem: #{operatingsystem}")
  end

  # Default to CentOS 7 Yum repo URL

  # Confirm presence of RPM-related resources
  it { should contain_yumrepo('opendaylight-4-testing') }
  it { should contain_package('opendaylight') }

  # Confirm relationships between RPM-related resources
  it { should contain_package('opendaylight').that_requires('Yumrepo[opendaylight-4-testing]') }
  it { should contain_yumrepo('opendaylight-4-testing').that_comes_before('Package[opendaylight]') }

  # Confirm properties of RPM-related resources
  # NB: These hashes don't work with Ruby 1.8.7, but we
  #   don't support 1.8.7 so that's okay. See issue #36.
  it {
    should contain_yumrepo('opendaylight-4-testing').with(
      'enabled'     => '1',
      'gpgcheck'    => '0',
      'descr'       => 'CentOS CBS OpenDaylight Berillium testing repository',
      'baseurl'     => yum_repo,
    )
  }
  it {
    should contain_package('opendaylight').with(
      'ensure'   => 'present',
    )
  }
end

# Shared tests for unsupported OSs
def unsupported_os_tests(options = {})
  # Extract params
  expected_msg = options.fetch(:expected_msg)

  # Confirm that classes fail on unsupported OSs
  it { expect { should contain_class('opendaylight') }.to raise_error(Puppet::Error, /#{expected_msg}/) }
  it { expect { should contain_class('opendaylight::install') }.to raise_error(Puppet::Error, /#{expected_msg}/) }
  it { expect { should contain_class('opendaylight::config') }.to raise_error(Puppet::Error, /#{expected_msg}/) }
  it { expect { should contain_class('opendaylight::service') }.to raise_error(Puppet::Error, /#{expected_msg}/) }

  # Confirm that other resources fail on unsupported OSs
  it { expect { should contain_yumrepo('opendaylight-4-testing') }.to raise_error(Puppet::Error, /#{expected_msg}/) }
  it { expect { should contain_package('opendaylight') }.to raise_error(Puppet::Error, /#{expected_msg}/) }
  it { expect { should contain_service('opendaylight') }.to raise_error(Puppet::Error, /#{expected_msg}/) }
  it { expect { should contain_file('org.apache.karaf.features.cfg') }.to raise_error(Puppet::Error, /#{expected_msg}/) }
end
