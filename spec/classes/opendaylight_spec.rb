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
            # TODO: Call supported-OS-specific tests
            it { should compile }
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
            # TODO: Call supported-OS-specific tests
            it { should compile }
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

    # All tests for unsupported OS families
    ['Debian', 'Suse', 'Solaris'].each do |osfamily|
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
end
