require 'puppetlabs_spec_helper/module_spec_helper'

# Customize filters to ignore 3rd-party code
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
  'Package[curl]',
  'Stage[deploy]',
  'Stage[deploy_app]',
  'Stage[deploy_infra]',
  'Stage[runtime]',
  'Stage[setup_app]',
  'Stage[setup_infra]',
]
RSpec::Puppet::Coverage.filters.push(*custom_filters)

# Tests that are common to all possible configurations
def generic_tests(yum_repo)
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
    )
  }
end

# Shared tests that specialize in testing Karaf feature installs
def karaf_feature_tests(features)
  # Confirm properties of other resources
  # NB: These hashes don't work with Ruby 1.8.7, but we
  #   don't support 1.8.7 so that's okay. See issue #36.
  it {
    should contain_file('org.apache.karaf.features.cfg').with(
      'ensure'      => 'file',
      'path'        => '/opt/opendaylight/etc/org.apache.karaf.features.cfg',
      'content'     => /^featuresBoot=#{features.join(",")}/
    )
  }
end

def install_method_tests(method, yum_repo, tarball_url='', unitfile_url='')
  case method
  when 'rpm'
    # Confirm presence of RPM-related resources
    it { should contain_yumrepo('opendaylight') }
    it { should contain_package('opendaylight') }

    # Confirm relationships between RPM-related resources
    it { should contain_package('opendaylight').that_requires('Yumrepo[opendaylight]') }
    it { should contain_yumrepo('opendaylight').that_comes_before('Package[opendaylight]') }

    # Confirm properties of RPM-related resources
    # NB: These hashes don't work with Ruby 1.8.7, but we
    #   don't support 1.8.7 so that's okay. See issue #36.
    it {
      should contain_yumrepo('opendaylight').with(
        'enabled'     => '1',
        'gpgcheck'    => '0',
        'descr'       => 'OpenDaylight SDN controller',
        'baseurl'     => yum_repo,
      )
    }
    it {
      should contain_package('opendaylight').with(
        'ensure'   => 'present',
      )
    }
  when 'tarball'
    if tarball_url == ''
      fail('Expected tarball_url param')
    end

    if unitfile_url == ''
      fail('Expected unitfile_url param')
    end

    # Confirm presence of tarball-related resources
    it { should contain_archive('opendaylight') }
    it { should contain_archive('opendaylight-systemd') }
    it { should contain_class('java') }
    it { should contain_file('/opt/opendaylight/') }
    it { should contain_file('/usr/lib/systemd/system/opendaylight.service') }
    it { should contain_user('odl') }
    it { should contain_group('odl') }

    # Confirm relationships between tarball-related resources
    it { should contain_archive('opendaylight').that_comes_before('File[/opt/opendaylight/]') }
    it { should contain_archive('opendaylight').that_comes_before('User[odl]') }
    it { should contain_archive('opendaylight-systemd').that_comes_before('File[/usr/lib/systemd/system/opendaylight.service]') }
    it { should contain_file('/opt/opendaylight/').that_requires('Archive[opendaylight]') }
    it { should contain_file('/opt/opendaylight/').that_requires('Group[odl]') }
    it { should contain_file('/opt/opendaylight/').that_requires('User[odl]') }
    it { should contain_file('/usr/lib/systemd/system/opendaylight.service').that_requires('Archive[opendaylight-systemd]') }
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
      should contain_package('java').with(
        'name' => 'java-1.7.0-openjdk',
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
      should contain_file('/usr/lib/systemd/system/opendaylight.service').with(
        'ensure'  => 'file',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
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

    # Verify that there are no unexpected resources from RPM-type installs
    it { should_not contain_yumrepo('opendaylight') }
    it { should_not contain_package('opendaylight') }
  else
    fail("Unexpected install method: #{method}")
  end
end

# Shared tests for unsupported OSs
def unsupported_os_tests(expected_err_msg)
  # Confirm that classes fail on unsupported OSs
  it { expect { should contain_class('opendaylight') }.to raise_error(Puppet::Error, /#{expected_err_msg}/) }
  it { expect { should contain_class('opendaylight::install') }.to raise_error(Puppet::Error, /#{expected_err_msg}/) }
  it { expect { should contain_class('opendaylight::config') }.to raise_error(Puppet::Error, /#{expected_err_msg}/) }
  it { expect { should contain_class('opendaylight::service') }.to raise_error(Puppet::Error, /#{expected_err_msg}/) }

  # Confirm that other resources fail on unsupported OSs
  it { expect { should contain_yumrepo('opendaylight') }.to raise_error(Puppet::Error, /#{expected_err_msg}/) }
  it { expect { should contain_package('opendaylight') }.to raise_error(Puppet::Error, /#{expected_err_msg}/) }
  it { expect { should contain_service('opendaylight') }.to raise_error(Puppet::Error, /#{expected_err_msg}/) }
  it { expect { should contain_file('org.apache.karaf.features.cfg') }.to raise_error(Puppet::Error, /#{expected_err_msg}/) }
end
