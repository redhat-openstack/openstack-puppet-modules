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

        # This is the Fedora Yum repo URL
        yum_repo = 'https://copr-be.cloud.fedoraproject.org/results/dfarrell07/OpenDaylight/fedora-$releasever-$basearch/'

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
            generic_tests(yum_repo)
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
            unsupported_os_tests("Unsupported OS: #{operatingsystem} #{operatingsystemmajrelease}")
          end
        end
      end

      # All tests for CentOS
      describe 'CentOS' do
        operatingsystem = 'CentOS'

        # This is the CentOS 7 Yum repo URL
        yum_repo = 'https://copr-be.cloud.fedoraproject.org/results/dfarrell07/OpenDaylight/epel-7-$basearch/'

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
            generic_tests(yum_repo)
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
            unsupported_os_tests("Unsupported OS: #{operatingsystem} #{operatingsystemmajrelease}")
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
        unsupported_os_tests("Unsupported OS family: #{osfamily}")
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
    # This is the CentOS 7 Yum repo URL
    yum_repo = 'https://copr-be.cloud.fedoraproject.org/results/dfarrell07/OpenDaylight/epel-7-$basearch/'
    describe 'using default features' do
      # NB: This list should be the same as the one in opendaylight::params
      # TODO: Remove this possible source of bugs^^
      default_features = ['config', 'standard', 'region', 'package', 'kar', 'ssh', 'management']
      context 'and not passing extra features' do
        let(:facts) {{
          :osfamily => osfamily,
          :operatingsystem => operatingsystem,
          :operatingsystemmajrelease => operatingsystemmajrelease,
        }}

        let(:params) {{ }}

        # Run shared tests applicable to all supported OSs
        # Note that this function is defined in spec_helper
        generic_tests(yum_repo)

        # Run test that specialize in checking Karaf feature installs
        # Note that this function is defined in spec_helper
        karaf_feature_tests(default_features)
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
        generic_tests(yum_repo)

        # Run test that specialize in checking Karaf feature installs
        # Note that this function is defined in spec_helper
        karaf_feature_tests(default_features + extra_features)
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
        generic_tests(yum_repo)

        # Run test that specialize in checking Karaf feature installs
        # Note that this function is defined in spec_helper
        karaf_feature_tests(default_features)
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
        generic_tests(yum_repo)

        # Run test that specialize in checking Karaf feature installs
        # Note that this function is defined in spec_helper
        karaf_feature_tests(default_features + extra_features)
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
    # This is the CentOS 7 Yum repo URL
    yum_repo = 'https://copr-be.cloud.fedoraproject.org/results/dfarrell07/OpenDaylight/epel-7-$basearch/'

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
      generic_tests(yum_repo)

      # Run test that specialize in checking Karaf feature installs
      # Note that this function is defined in spec_helper
      install_method_tests('rpm', yum_repo)
    end

    # All tests for tarball install method
    describe 'tarball' do
      describe 'using default tarball_url' do
        tarball_url = 'https://nexus.opendaylight.org/content/groups/public/org/opendaylight/integration/distribution-karaf/0.2.2-Helium-SR2/distribution-karaf-0.2.2-Helium-SR2.tar.gz'
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
          }}

          # Run shared tests applicable to all supported OSs
          # Note that this function is defined in spec_helper
          generic_tests(yum_repo)

          # Run test that specialize in checking Karaf feature installs
          # Note that this function is defined in spec_helper
          install_method_tests('tarball', yum_repo, tarball_url, unitfile_url)
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
          generic_tests(yum_repo)

          # Run test that specialize in checking Karaf feature installs
          # Note that this function is defined in spec_helper
          install_method_tests('tarball', yum_repo, tarball_url, unitfile_url)
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
          generic_tests(yum_repo)

          # Run test that specialize in checking Karaf feature installs
          # Note that this function is defined in spec_helper
          install_method_tests('tarball', yum_repo, tarball_url, unitfile_url)
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
          generic_tests(yum_repo)

          # Run test that specialize in checking Karaf feature installs
          # Note that this function is defined in spec_helper
          install_method_tests('tarball', yum_repo, tarball_url, unitfile_url)
        end
      end
    end
  end
end
