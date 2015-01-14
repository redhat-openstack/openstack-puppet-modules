require 'spec_helper'

describe 'opendaylight' do
  context 'supported operating systems' do
    ['19', '20', '21'].each do |lsbmajdistrelease|
      osfamily = 'RedHat'
      operatingsystem = 'Fedora'
      describe "opendaylight class without any params on #{osfamily}:#{operatingsystem} #{lsbmajdistrelease}" do
        let(:params) {{ }}
        let(:facts) {{
          :osfamily => osfamily,
          :operatingsystem => operatingsystem,
          :lsbmajdistrelease => lsbmajdistrelease,
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
    describe 'opendaylight class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect { should contain_package('opendaylight') }.to raise_error(Puppet::Error, /Unsupported OS/) }
    end
  end
end
