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

        # Run shared tests applicable to all valid OSs
        # Note that this function is defined in spec_helper
        valid_os_tests

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

        # Run shared tests applicable to all valid OSs
        # Note that this function is defined in spec_helper
        valid_os_tests

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

        # Confirm that classes fail on unsupported OSs
        it { expect { should contain_class('opendaylight') }.to raise_error(Puppet::Error, /Unsupported OS: #{operatingsystem} #{operatingsystemmajrelease}/) }
        it { expect { should contain_class('opendaylight::install') }.to raise_error(Puppet::Error, /Unsupported OS: #{operatingsystem} #{operatingsystemmajrelease}/) }
        it { expect { should contain_class('opendaylight::config') }.to raise_error(Puppet::Error, /Unsupported OS: #{operatingsystem} #{operatingsystemmajrelease}/) }
        it { expect { should contain_class('opendaylight::service') }.to raise_error(Puppet::Error, /Unsupported OS: #{operatingsystem} #{operatingsystemmajrelease}/) }

        # Confirm that other resources fail on unsupported OSs
        it { expect { should contain_yumrepo('opendaylight') }.to raise_error(Puppet::Error, /Unsupported OS: #{operatingsystem} #{operatingsystemmajrelease}/) }
        it { expect { should contain_package('opendaylight') }.to raise_error(Puppet::Error, /Unsupported OS: #{operatingsystem} #{operatingsystemmajrelease}/) }
        it { expect { should contain_service('opendaylight') }.to raise_error(Puppet::Error, /Unsupported OS: #{operatingsystem} #{operatingsystemmajrelease}/) }
        it { expect { should contain_file('org.apache.karaf.features.cfg') }.to raise_error(Puppet::Error, /Unsupported OS: #{operatingsystem} #{operatingsystemmajrelease}/) }
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

        # Confirm that classes fail on unsupported OSs
        it { expect { should contain_class('opendaylight') }.to raise_error(Puppet::Error, /Unsupported OS: #{operatingsystem} #{operatingsystemmajrelease}/) }
        it { expect { should contain_class('opendaylight::install') }.to raise_error(Puppet::Error, /Unsupported OS: #{operatingsystem} #{operatingsystemmajrelease}/) }
        it { expect { should contain_class('opendaylight::config') }.to raise_error(Puppet::Error, /Unsupported OS: #{operatingsystem} #{operatingsystemmajrelease}/) }
        it { expect { should contain_class('opendaylight::service') }.to raise_error(Puppet::Error, /Unsupported OS: #{operatingsystem} #{operatingsystemmajrelease}/) }

        # Confirm that other resources fail on unsupported OSs
        it { expect { should contain_yumrepo('opendaylight') }.to raise_error(Puppet::Error, /Unsupported OS: #{operatingsystem} #{operatingsystemmajrelease}/) }
        it { expect { should contain_package('opendaylight') }.to raise_error(Puppet::Error, /Unsupported OS: #{operatingsystem} #{operatingsystemmajrelease}/) }
        it { expect { should contain_service('opendaylight') }.to raise_error(Puppet::Error, /Unsupported OS: #{operatingsystem} #{operatingsystemmajrelease}/) }
        it { expect { should contain_file('org.apache.karaf.features.cfg') }.to raise_error(Puppet::Error, /Unsupported OS: #{operatingsystem} #{operatingsystemmajrelease}/) }
      end
    end

    # Test unsupported OS families
    ['Debian', 'Suse', 'Solaris'].each do |osfamily|
      describe "opendaylight class without any params on #{osfamily}" do
        let(:facts) {{
          :osfamily => osfamily,
        }}

        # Confirm that classes fail on unsupported OS families
        it { expect { should contain_class('opendaylight') }.to raise_error(Puppet::Error, /Unsupported OS family: #{osfamily}/) }
        it { expect { should contain_class('opendaylight::install') }.to raise_error(Puppet::Error, /Unsupported OS family: #{osfamily}/) }
        it { expect { should contain_class('opendaylight::config') }.to raise_error(Puppet::Error, /Unsupported OS family: #{osfamily}/) }
        it { expect { should contain_class('opendaylight::service') }.to raise_error(Puppet::Error, /Unsupported OS family: #{osfamily}/) }

        # Confirm that other resources fail on unsupported OS families
        it { expect { should contain_yumrepo('opendaylight') }.to raise_error(Puppet::Error, /Unsupported OS family: #{osfamily}/) }
        it { expect { should contain_package('opendaylight') }.to raise_error(Puppet::Error, /Unsupported OS family: #{osfamily}/) }
        it { expect { should contain_service('opendaylight') }.to raise_error(Puppet::Error, /Unsupported OS family: #{osfamily}/) }
        it { expect { should contain_file('org.apache.karaf.features.cfg') }.to raise_error(Puppet::Error, /Unsupported OS family: #{osfamily}/) }
      end
    end
  end
end
