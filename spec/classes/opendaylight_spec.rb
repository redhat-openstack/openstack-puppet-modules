require 'spec_helper'

describe 'opendaylight' do
  context 'supported operating systems' do
    osfamily = 'RedHat'
    ['20', '21'].each do |operatingsystemmajrelease|
      operatingsystem = 'Fedora'
      describe "opendaylight class without any params on #{osfamily}:#{operatingsystem} #{operatingsystemmajrelease}" do
        let(:params) {{ }}
        let(:facts) {{
          :osfamily => osfamily,
          :operatingsystem => operatingsystem,
          :operatingsystemmajrelease => operatingsystemmajrelease,
        }}

        # Run shared tests applicable to all supported OSs
        # Note that this function is defined in spec_helper
        supported_os_tests

        # The yum repo URLs for Fedora and CentOS are different, so check here
        it { should contain_yumrepo('opendaylight').with_baseurl('https://copr-be.cloud.fedoraproject.org/results/dfarrell07/OpenDaylight/fedora-$releasever-$basearch/') }

      end
    end
    ['7'].each do |operatingsystemmajrelease|
      operatingsystem = 'CentOS'
      describe "opendaylight class without any params on #{osfamily}:#{operatingsystem} #{operatingsystemmajrelease}" do
        let(:params) {{ }}
        let(:facts) {{
          :osfamily => osfamily,
          :operatingsystem => operatingsystem,
          :operatingsystemmajrelease => operatingsystemmajrelease,
        }}

        # Run shared tests applicable to all supported OSs
        # Note that this function is defined in spec_helper
        supported_os_tests

        # The yum repo URLs for Fedora and CentOS are different, so check here
        it { should contain_yumrepo('opendaylight').with_baseurl('https://copr-be.cloud.fedoraproject.org/results/dfarrell07/OpenDaylight/epel-7-$basearch/') }
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
        unsupported_os_tests(operatingsystem, operatingsystemmajrelease)

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
        unsupported_os_tests(operatingsystem, operatingsystemmajrelease)

      end
    end

    # Test unsupported OS families
    ['Debian', 'Suse', 'Solaris'].each do |osfamily|
      describe "opendaylight class without any params on #{osfamily}" do
        let(:facts) {{
          :osfamily => osfamily,
        }}

        # Run shared tests applicable to all unsupported OS families
        # Note that this function is defined in spec_helper
        unsupported_os_family_tests(osfamily)

      end
    end
  end
end
