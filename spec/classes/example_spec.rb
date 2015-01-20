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

        # Confirm presense of other resources
        it { should contain_service('opendaylight') }
        it { should contain_yumrepo('opendaylight') }
        it { should contain_package('opendaylight') }

        # Confirm relationships between other resources
        it { should contain_package('opendaylight').that_requires('Yumrepo[opendaylight]') }
        it { should contain_yumrepo('opendaylight').that_comes_before('Package[opendaylight]') }

        # Confirm properties of other resources
        it {
          should contain_yumrepo('opendaylight').with(
            'enabled'   => '1',
            'gpgcheck'  => '0',
            'descr'     => 'OpenDaylight SDN controller',
            'baseurl'   => 'https://copr-be.cloud.fedoraproject.org/results/dfarrell07/OpenDaylight/fedora-$releasever-$basearch/',
          )
        }
        it { should contain_package('opendaylight').with_ensure('present') }
        it {
          should contain_service('opendaylight').with(
            'ensure'      => 'running',
            'enable'      => 'true',
            'hasstatus'   => 'true',
            'hasrestart'  => 'true',
          )
        }
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

        # Confirm presense of other resources
        it { should contain_service('opendaylight') }
        it { should contain_yumrepo('opendaylight') }
        it { should contain_package('opendaylight') }

        # Confirm relationships between other resources
        it { should contain_package('opendaylight').that_requires('Yumrepo[opendaylight]') }
        it { should contain_yumrepo('opendaylight').that_comes_before('Package[opendaylight]') }

        # Confirm properties of other resources
        it {
          should contain_yumrepo('opendaylight').with(
            'enabled'   => '1',
            'gpgcheck'  => '0',
            'descr'     => 'OpenDaylight SDN controller',
            'baseurl'   => 'https://copr-be.cloud.fedoraproject.org/results/dfarrell07/OpenDaylight/epel-7-$basearch/'
          )
        }
        it { should contain_package('opendaylight').with_ensure('present') }
        it {
          should contain_service('opendaylight').with(
            'ensure'      => 'running',
            'enable'      => 'true',
            'hasstatus'   => 'true',
            'hasrestart'  => 'true',
          )
        }
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
      end
    end
  end
end
