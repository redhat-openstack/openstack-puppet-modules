require 'spec_helper'

describe 'opendaylight' do
  context 'supported operating systems' do
    osfamily = 'RedHat'
    ['19', '20', '21'].each do |operatingsystemmajrelease|
      operatingsystem = 'Fedora'
      describe "opendaylight class without any params on #{osfamily}:#{operatingsystem} #{operatingsystemmajrelease}" do
        let(:params) {{ }}
        let(:facts) {{
          :osfamily => osfamily,
          :operatingsystem => operatingsystem,
          :operatingsystemmajrelease => operatingsystemmajrelease,
        }}

        it { should compile.with_all_deps }

        it { should contain_class('opendaylight::params') }
        it { should contain_class('opendaylight::install').that_comes_before('opendaylight::config') }
        it { should contain_class('opendaylight::config') }
        it { should contain_class('opendaylight::service').that_subscribes_to('opendaylight::config') }

        it { should contain_service('opendaylight') }
        it { should contain_package('opendaylight').with_ensure('present') }
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

        it { should compile.with_all_deps }

        it { should contain_class('opendaylight::params') }
        it { should contain_class('opendaylight::install').that_comes_before('opendaylight::config') }
        it { should contain_class('opendaylight::config') }
        it { should contain_class('opendaylight::service').that_subscribes_to('opendaylight::config') }

        it { should contain_service('opendaylight') }
        it { should contain_package('opendaylight').with_ensure('present') }
      end
    end
  end

  context 'unsupported operating system' do
    ['18', '22'].each do |operatingsystemmajrelease|
      osfamily = 'RedHat'
      operatingsystem = 'Fedora'
      describe "opendaylight class without any params on #{osfamily}:#{operatingsystem} #{operatingsystemmajrelease}" do
        let(:facts) {{
          :osfamily => osfamily,
          :operatingsystem => operatingsystem,
          :operatingsystemmajrelease => operatingsystemmajrelease,
        }}

        it { expect { should contain_package('opendaylight') }.to raise_error(Puppet::Error, /Unsupported OS: #{operatingsystem} #{operatingsystemmajrelease}/) }
      end
    end

    ['5', '6', '8'].each do |operatingsystemmajrelease|
      osfamily = 'RedHat'
      operatingsystem = 'CentOS'
      describe "opendaylight class without any params on #{osfamily}:#{operatingsystem} #{operatingsystemmajrelease}" do
        let(:facts) {{
          :osfamily => osfamily,
          :operatingsystem => operatingsystem,
          :operatingsystemmajrelease => operatingsystemmajrelease,
        }}

        it { expect { should contain_package('opendaylight') }.to raise_error(Puppet::Error, /Unsupported OS: #{operatingsystem} #{operatingsystemmajrelease}/) }
      end
    end

    ['Debian', 'Suse', 'Solaris'].each do |osfamily|
      describe "opendaylight class without any params on #{osfamily}" do
        let(:facts) {{
          :osfamily => osfamily,
        }}

        it { expect { should contain_package('opendaylight') }.to raise_error(Puppet::Error, /Unsupported OS family: #{osfamily}/) }
      end
    end
  end
end
