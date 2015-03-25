require 'spec_helper'

describe 'opendaylight' do
  # All tests that check OS support/not-support
  describe 'OS support tests' do
    # All tests for OSs in the Red Hat family (CentOS, Fedora)
    describe 'OS family Red Hat ' do
      osfamily = 'RedHat'
      # All tests for Fedora
      describe 'Fedora' do
        operatingsystem = 'Fedora'

        # All tests for supported versions of Fedora
        ['20', '21'].each do |operatingsystemmajrelease|
          context "#{operatingsystemmajrelease}" do
            let(:facts) {{
              :osfamily => osfamily,
              :operatingsystem => operatingsystem,
              :operatingsystemmajrelease => operatingsystemmajrelease,
            }}
            # Run shared tests applicable to all supported OSs
            # Note that this function is defined in spec_helper
            generic_tests

            # Run test that specialize in checking rpm-based installs
            # NB: Only testing defaults here, specialized rpm tests elsewhere
            # Note that this function is defined in spec_helper
            rpm_install_tests(operatingsystem: operatingsystem)

            # Run test that specialize in checking Karaf feature installs
            # NB: Only testing defaults here, specialized Karaf tests elsewhere
            # Note that this function is defined in spec_helper
            karaf_feature_tests
          end
        end

        # All tests for unsupported versions of Fedora
        ['18', '19', '22'].each do |operatingsystemmajrelease|
          context "#{operatingsystemmajrelease}" do
            let(:facts) {{
              :osfamily => osfamily,
              :operatingsystem => operatingsystem,
              :operatingsystemmajrelease => operatingsystemmajrelease,
            }}
            # Run shared tests applicable to all unsupported OSs
            # Note that this function is defined in spec_helper
            expected_msg = "Unsupported OS: #{operatingsystem} #{operatingsystemmajrelease}"
            unsupported_os_tests(expected_msg: expected_msg)
          end
        end
      end

      # All tests for CentOS
      describe 'CentOS' do
        operatingsystem = 'CentOS'

        # All tests for supported versions of CentOS
        ['7'].each do |operatingsystemmajrelease|
          context "#{operatingsystemmajrelease}" do
            let(:facts) {{
              :osfamily => osfamily,
              :operatingsystem => operatingsystem,
              :operatingsystemmajrelease => operatingsystemmajrelease,
            }}
            # Run shared tests applicable to all supported OSs
            # Note that this function is defined in spec_helper
            generic_tests

            # Run test that specialize in checking rpm-based installs
            # NB: Only testing defaults here, specialized rpm tests elsewhere
            # Note that this function is defined in spec_helper
            rpm_install_tests

            # Run test that specialize in checking Karaf feature installs
            # NB: Only testing defaults here, specialized Karaf tests elsewhere
            # Note that this function is defined in spec_helper
            karaf_feature_tests
          end
        end

        # All tests for unsupported versions of CentOS
        ['5', '6', '8'].each do |operatingsystemmajrelease|
          context "#{operatingsystemmajrelease}" do
            let(:facts) {{
              :osfamily => osfamily,
              :operatingsystem => operatingsystem,
              :operatingsystemmajrelease => operatingsystemmajrelease,
            }}
            # Run shared tests applicable to all unsupported OSs
            # Note that this function is defined in spec_helper
            expected_msg = "Unsupported OS: #{operatingsystem} #{operatingsystemmajrelease}"
            unsupported_os_tests(expected_msg: expected_msg)
          end
        end
      end
    end

    # All tests for OSs in the Debian family (Ubuntu)
    describe 'OS family Debian' do
      osfamily = 'Debian'

      # All tests for Ubuntu 14.04
      describe 'Ubuntu' do
        operatingsystem = 'Ubuntu'

        # All tests for supported versions of Ubuntu
        ['14.04'].each do |operatingsystemmajrelease|
          context "#{operatingsystemmajrelease}" do
            let(:facts) {{
              :osfamily => osfamily,
              :operatingsystem => operatingsystem,
              :operatingsystemmajrelease => operatingsystemmajrelease,
              # TODO: Do more elegantly. Java mod uses codenames to ID version.
              :lsbdistcodename => 'trusty',
              :architecture => 'x86_64',
              :path => ['/usr/local/bin', '/usr/bin', '/bin'],
            }}

            # NB: Only tarball installs are supported for Debian family OSs
            let(:params) {{
                :install_method => 'tarball',
            }}

            # Run shared tests applicable to all supported OSs
            # Note that this function is defined in spec_helper
            generic_tests

            # Run test that specialize in checking tarball-based installs
            # NB: Only testing defaults here, specialized tarball tests elsewhere
            # Passing osfamily required to do upstart vs systemd (default) checks
            # Note that this function is defined in spec_helper
            tarball_install_tests(osfamily: osfamily)

            # Run test that specialize in checking Karaf feature installs
            # NB: Only testing defaults here, specialized Karaf tests elsewhere
            # Note that this function is defined in spec_helper
            karaf_feature_tests
          end
        end

        # All tests for unsupported versions of Ubuntu
        ['12.04', '12.10', '13.04', '13.10', '14.10', '15.04'].each do |operatingsystemmajrelease|
          context "#{operatingsystemmajrelease}" do
            let(:facts) {{
              :osfamily => osfamily,
              :operatingsystem => operatingsystem,
              :operatingsystemmajrelease => operatingsystemmajrelease,
            }}
            # Run shared tests applicable to all unsupported OSs
            # Note that this function is defined in spec_helper
            expected_msg = "Unsupported OS: #{operatingsystem} #{operatingsystemmajrelease}"
            unsupported_os_tests(expected_msg: expected_msg)
          end
        end
      end
    end

    # All tests for unsupported OS families
    ['Suse', 'Solaris'].each do |osfamily|
      context "OS family #{osfamily}" do
        let(:facts) {{
          :osfamily => osfamily,
        }}

        # Run shared tests applicable to all unsupported OSs
        # Note that this function is defined in spec_helper
        expected_msg = "Unsupported OS family: #{osfamily}"
        unsupported_os_tests(expected_msg: expected_msg)
      end
    end
  end

  # All Karaf feature tests
  describe 'Karaf feature tests' do
    # Non-OS-type tests assume CentOS 7
    #   See issue #43 for reasoning:
    #   https://github.com/dfarrell07/puppet-opendaylight/issues/43#issue-57343159
    osfamily = 'RedHat'
    operatingsystem = 'CentOS'
    operatingsystemmajrelease = '7'
    describe 'using default features' do
      context 'and not passing extra features' do
        let(:facts) {{
          :osfamily => osfamily,
          :operatingsystem => operatingsystem,
          :operatingsystemmajrelease => operatingsystemmajrelease,
        }}

        let(:params) {{ }}

        # Run shared tests applicable to all supported OSs
        # Note that this function is defined in spec_helper
        generic_tests

        # Run test that specialize in checking Karaf feature installs
        # Note that this function is defined in spec_helper
        karaf_feature_tests
      end

      context 'and passing extra features' do
        let(:facts) {{
          :osfamily => osfamily,
          :operatingsystem => operatingsystem,
          :operatingsystemmajrelease => operatingsystemmajrelease,
        }}

        # These are real but arbitrarily chosen features
        extra_features = ['odl-base-all', 'odl-ovsdb-all']
        let(:params) {{
          :extra_features => extra_features,
        }}

        # Run shared tests applicable to all supported OSs
        # Note that this function is defined in spec_helper
        generic_tests

        # Run test that specialize in checking Karaf feature installs
        # Note that this function is defined in spec_helper
        karaf_feature_tests(extra_features: extra_features)
      end
    end

    describe 'overriding default features' do
      default_features = ['standard', 'ssh']
      context 'and not passing extra features' do
        let(:facts) {{
          :osfamily => osfamily,
          :operatingsystem => operatingsystem,
          :operatingsystemmajrelease => operatingsystemmajrelease,
        }}

        let(:params) {{
          :default_features => default_features,
        }}

        # Run shared tests applicable to all supported OSs
        # Note that this function is defined in spec_helper
        generic_tests

        # Run test that specialize in checking Karaf feature installs
        # Note that this function is defined in spec_helper
        karaf_feature_tests(default_features: default_features)
      end

      context 'and passing extra features' do
        let(:facts) {{
          :osfamily => osfamily,
          :operatingsystem => operatingsystem,
          :operatingsystemmajrelease => operatingsystemmajrelease,
        }}

        # These are real but arbitrarily chosen features
        extra_features = ['odl-base-all', 'odl-ovsdb-all']
        let(:params) {{
          :default_features => default_features,
          :extra_features => extra_features,
        }}

        # Run shared tests applicable to all supported OSs
        # Note that this function is defined in spec_helper
        generic_tests

        # Run test that specialize in checking Karaf feature installs
        # Note that this function is defined in spec_helper
        karaf_feature_tests(default_features: default_features, extra_features: extra_features)
      end
    end
  end

  # All install method tests
  describe 'install method tests' do
    # Non-OS-type tests assume CentOS 7
    #   See issue #43 for reasoning:
    #   https://github.com/dfarrell07/puppet-opendaylight/issues/43#issue-57343159
    osfamily = 'RedHat'
    operatingsystem = 'CentOS'
    operatingsystemrelease = '7.0'
    operatingsystemmajrelease = '7'

    # All tests for RPM install method
    context 'RPM' do
      let(:facts) {{
        :osfamily => osfamily,
        :operatingsystem => operatingsystem,
        :operatingsystemmajrelease => operatingsystemmajrelease,
      }}

      let(:params) {{
          :install_method => 'rpm',
      }}

      # Run shared tests applicable to all supported OSs
      # Note that this function is defined in spec_helper
      generic_tests

      # Run test that specialize in checking RPM-based installs
      # Note that this function is defined in spec_helper
      rpm_install_tests
    end

    # All tests for tarball install method
    describe 'tarball' do
      describe 'using default tarball_url' do
        context 'using default unitfile_url' do
          let(:facts) {{
            :osfamily => osfamily,
            :operatingsystem => operatingsystem,
            :operatingsystemrelease => operatingsystemrelease,
            :operatingsystemmajrelease => operatingsystemmajrelease,
            :path => ['/usr/local/bin', '/usr/bin', '/bin'],
          }}

          let(:params) {{
              :install_method => 'tarball',
          }}

          # Run shared tests applicable to all supported OSs
          # Note that this function is defined in spec_helper
          generic_tests

          # Run test that specialize in checking tarball-based installs
          # Note that this function is defined in spec_helper
          tarball_install_tests
        end

        context 'overriding default unitfile_url' do
          # Doesn't matter if this is valid, just that it honors what we pass
          unitfile_url = 'fake_unitfile'
          let(:facts) {{
            :osfamily => osfamily,
            :operatingsystem => operatingsystem,
            :operatingsystemrelease => operatingsystemrelease,
            :operatingsystemmajrelease => operatingsystemmajrelease,
            :path => ['/usr/local/bin', '/usr/bin', '/bin'],
          }}

          let(:params) {{
              :install_method => 'tarball',
              :unitfile_url => unitfile_url,
          }}

          # Run shared tests applicable to all supported OSs
          # Note that this function is defined in spec_helper
          generic_tests

          # Run test that specialize in checking tarball-based installs
          # Note that this function is defined in spec_helper
          tarball_install_tests(unitfile_url: unitfile_url)
        end
      end

      describe 'overriding default tarball_url' do
        # Doesn't matter if this is valid, just that it honors what we pass
        tarball_url = 'fake_tarball'
        context 'using default unitfile_url' do
          unitfile_url = 'https://github.com/dfarrell07/opendaylight-systemd/archive/master/opendaylight-unitfile.tar.gz'
          let(:facts) {{
            :osfamily => osfamily,
            :operatingsystem => operatingsystem,
            :operatingsystemrelease => operatingsystemrelease,
            :operatingsystemmajrelease => operatingsystemmajrelease,
            :path => ['/usr/local/bin', '/usr/bin', '/bin'],
          }}

          let(:params) {{
              :install_method => 'tarball',
              :tarball_url => tarball_url,
          }}

          # Run shared tests applicable to all supported OSs
          # Note that this function is defined in spec_helper
          generic_tests

          # Run test that specialize in checking tarball-based installs
          # Note that this function is defined in spec_helper
          tarball_install_tests(tarball_url: tarball_url)
        end

        context 'overriding default unitfile_url' do
          # Doesn't matter if this is valid, just that it honors what we pass
          unitfile_url = 'fake_unitfile'
          let(:facts) {{
            :osfamily => osfamily,
            :operatingsystem => operatingsystem,
            :operatingsystemrelease => operatingsystemrelease,
            :operatingsystemmajrelease => operatingsystemmajrelease,
            :path => ['/usr/local/bin', '/usr/bin', '/bin'],
          }}

          let(:params) {{
              :install_method => 'tarball',
              :tarball_url => tarball_url,
              :unitfile_url => unitfile_url,
          }}

          # Run shared tests applicable to all supported OSs
          # Note that this function is defined in spec_helper
          generic_tests

          # Run test that specialize in checking tarball-based installs
          # Note that this function is defined in spec_helper
          tarball_install_tests(tarball_url: tarball_url, unitfile_url: unitfile_url)
        end
      end
    end
  end
end
