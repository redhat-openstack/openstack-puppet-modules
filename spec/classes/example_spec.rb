require 'spec_helper'

describe 'kafka' do
  context 'supported operating systems' do
    ['Debian', 'RedHat'].each do |osfamily|
      describe "kafka class without any parameters on #{osfamily}" do
        let(:params) {{ }}
        let(:facts) {{
          :osfamily => osfamily,
        }}

        it { should compile.with_all_deps }

        it { should contain_class('kafka::params') }
        it { should contain_class('kafka::install').that_comes_before('kafka::config') }
        it { should contain_class('kafka::config') }
        it { should contain_class('kafka::service').that_subscribes_to('kafka::config') }

        it { should contain_service('kafka') }
        it { should contain_package('kafka').with_ensure('present') }
      end
    end
  end

  context 'unsupported operating system' do
    describe 'kafka class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect { should contain_package('kafka') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
