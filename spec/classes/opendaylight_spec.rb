require 'spec_helper'

describe 'opendaylight' do
  context 'supported operating systems' do
    osfamily = 'RedHat'
    ['20', '21'].each do |operatingsystemmajrelease|
      operatingsystem = 'Fedora'
      # This is the Fedora Yum repo URL
      yum_repo = 'https://copr-be.cloud.fedoraproject.org/results/dfarrell07/OpenDaylight/fedora-$releasever-$basearch/'
      describe "opendaylight class on #{osfamily}:#{operatingsystem} #{operatingsystemmajrelease}" do
        # Facts that are shared by all Fedora tests
        let(:facts) {{
          :osfamily => osfamily,
          :operatingsystem => operatingsystem,
          :operatingsystemmajrelease => operatingsystemmajrelease,
        }}

        describe "using default features" do
          # NB: This list should be the same as the one in opendaylight::params
          default_features = ['config', 'standard', 'region', 'package', 'kar', 'ssh', 'management']
          describe "and not passing extra features" do
            #extra_features = []
            let(:params) {{ }}

            # Run shared tests applicable to all supported OSs
            # Note that this function is defined in spec_helper
            supported_os_tests(yum_repo, default_features)
          end

          describe "and passing extra features" do
            # These are real but arbitrarily chosen features
            extra_features = ["odl-base-all", "odl-ovsdb-all"]
            let(:params) {{
              :extra_features => extra_features,
            }}

            # Run shared tests applicable to all supported OSs
            # Note that this function is defined in spec_helper
            supported_os_tests(yum_repo, default_features + extra_features)
          end
        end

        describe "overriding default features" do
          default_features = ["standard", "ssh"]
          describe "and not passing extra features" do
            extra_features = []
            let(:params) {{
              :default_features => default_features,
            }}

            # Run shared tests applicable to all supported OSs
            # Note that this function is defined in spec_helper
            supported_os_tests(yum_repo, default_features)
          end

          describe "and passing extra features" do
            # These are real but arbitrarily chosen features
            extra_features = ["odl-base-all", "odl-ovsdb-all"]
            let(:params) {{
              :default_features => default_features,
              :extra_features => extra_features,
            }}

            # Run shared tests applicable to all supported OSs
            # Note that this function is defined in spec_helper
            supported_os_tests(yum_repo, default_features + extra_features)
          end
        end
      end
    end
    ['7'].each do |operatingsystemmajrelease|
      operatingsystem = 'CentOS'
      # This is the CentOS 7 Yum repo URL
      yum_repo = 'https://copr-be.cloud.fedoraproject.org/results/dfarrell07/OpenDaylight/epel-7-$basearch/'
      describe "opendaylight class without any params on #{osfamily}:#{operatingsystem} #{operatingsystemmajrelease}" do
        # Facts that are shared by all Fedora tests
        let(:facts) {{
          :osfamily => osfamily,
          :operatingsystem => operatingsystem,
          :operatingsystemmajrelease => operatingsystemmajrelease,
        }}

        describe "using default features" do
          # NB: This list should be the same as the one in opendaylight::params
          default_features = ['config', 'standard', 'region', 'package', 'kar', 'ssh', 'management']
          describe "and not passing extra features" do
            #extra_features = []
            let(:params) {{ }}

            # Run shared tests applicable to all supported OSs
            # Note that this function is defined in spec_helper
            supported_os_tests(yum_repo, default_features)
          end

          describe "and passing extra features" do
            # These are real but arbitrarily chosen features
            extra_features = ["odl-base-all", "odl-ovsdb-all"]
            let(:params) {{
              :extra_features => extra_features,
            }}

            # Run shared tests applicable to all supported OSs
            # Note that this function is defined in spec_helper
            supported_os_tests(yum_repo, default_features + extra_features)
          end
        end

        describe "overriding default features" do
          default_features = ["standard", "ssh"]
          describe "and not passing extra features" do
            extra_features = []
            let(:params) {{
              :default_features => default_features,
            }}

            # Run shared tests applicable to all supported OSs
            # Note that this function is defined in spec_helper
            supported_os_tests(yum_repo, default_features)
          end

          describe "and passing extra features" do
            # These are real but arbitrarily chosen features
            extra_features = ["odl-base-all", "odl-ovsdb-all"]
            let(:params) {{
              :default_features => default_features,
              :extra_features => extra_features,
            }}

            # Run shared tests applicable to all supported OSs
            # Note that this function is defined in spec_helper
            supported_os_tests(yum_repo, default_features + extra_features)
          end
        end
      end
    end
  end

  context 'unsupported operating systems' do
    # Test unsupported versions of Fedora
    ['18', '19', '22'].each do |operatingsystemmajrelease|
      osfamily = 'RedHat'
      operatingsystem = 'Fedora'
      describe "opendaylight class without any params on #{osfamily}:#{operatingsystem} #{operatingsystemmajrelease}" do
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

    # Test unsupported versions of CentOS
    ['5', '6', '8'].each do |operatingsystemmajrelease|
      osfamily = 'RedHat'
      operatingsystem = 'CentOS'
      describe "opendaylight class without any params on #{osfamily}:#{operatingsystem} #{operatingsystemmajrelease}" do
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

    # Test unsupported OS families
    ['Debian', 'Suse', 'Solaris'].each do |osfamily|
      describe "opendaylight class without any params on #{osfamily}" do
        let(:facts) {{
          :osfamily => osfamily,
        }}

        # Run shared tests applicable to all unsupported OSs
        # Note that this function is defined in spec_helper
        unsupported_os_tests("Unsupported OS family: #{osfamily}")

      end
    end
  end
end
