require 'spec_helper'

describe 'opendaylight' do
  context 'supported operating systems' do
    ['RedHat'].each do |osfamily|
      describe "opendaylight class without any parameters on #{osfamily}" do
        let(:params) {{ }}
        let(:facts) {{
          :osfamily => osfamily,
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

      it { expect { should contain_package('opendaylight') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
