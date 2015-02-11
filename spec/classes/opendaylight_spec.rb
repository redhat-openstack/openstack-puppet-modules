require 'spec_helper'

describe 'opendaylight class' do
  # All tests that check OS support/not-support
  describe 'OS support tests' do
    # All tests for OSs in the Red Hat family (CentOS, Fedora)
    describe 'OS family Red Hat ' do
      let(:facts) {{
        :osfamily => 'RedHat',
      }}
      # All tests for Fedora
      describe 'Fedora' do
        operatingsystem = 'Fedora'
        let(:facts) {{
          :operatingsystem => operatingsystem,
        }}

        # This is the Fedora Yum repo URL
        yum_repo = 'https://copr-be.cloud.fedoraproject.org/results/dfarrell07/OpenDaylight/fedora-$releasever-$basearch/'

        # All tests for supported versions of Fedora
        ['20', '21'].each do |operatingsystemmajrelease|
          let(:facts) {{
            :operatingsystemmajrelease => operatingsystemmajrelease,
          }}
          context "#{operatingsystemmajrelease}" do
            # TODO: Call supported-OS-specific tests
            it { should compile }
          end
        end

        # All tests for unsupported versions of Fedora
        ['18', '19', '22'].each do |operatingsystemmajrelease|
          let(:facts) {{
            :operatingsystemmajrelease => operatingsystemmajrelease,
          }}
          context "#{operatingsystemmajrelease}" do
            # Run shared tests applicable to all unsupported OSs
            # Note that this function is defined in spec_helper
            #unsupported_os_tests("Unsupported OS: #{operatingsystem} #{operatingsystemmajrelease}")
          end
        end
      end

      # All tests for CentOS
      describe 'CentOS' do
        operatingsystem = 'CentOS'
        let(:facts) {{
          :operatingsystem => operatingsystem,
        }}

        # This is the CentOS 7 Yum repo URL
        yum_repo = 'https://copr-be.cloud.fedoraproject.org/results/dfarrell07/OpenDaylight/epel-7-$basearch/'

        # All tests for supported versions of Fedora
        ['7'].each do |operatingsystemmajrelease|
          let(:facts) {{
            :operatingsystemmajrelease => operatingsystemmajrelease,
          }}
          context "#{operatingsystemmajrelease}" do
            # TODO: Call supported-OS-specific tests
          end
        end

        # All tests for unsupported versions of Fedora
        ['5', '6', '8'].each do |operatingsystemmajrelease|
          let(:facts) {{
            :operatingsystemmajrelease => operatingsystemmajrelease,
          }}
          context "#{operatingsystemmajrelease}" do
            # Run shared tests applicable to all unsupported OSs
            # Note that this function is defined in spec_helper
            #unsupported_os_tests("Unsupported OS: #{operatingsystem} #{operatingsystemmajrelease}")
          end
        end
      end
    end

    # All tests for unsupported OS families
    ['Debian', 'Suse', 'Solaris'].each do |osfamily|
      describe "OS family #{osfamily}" do
        let(:facts) {{
          :osfamily => osfamily,
        }}

        # Run shared tests applicable to all unsupported OSs
        # Note that this function is defined in spec_helper
        #unsupported_os_tests("Unsupported OS family: #{osfamily}")
      end
    end
  end
end
