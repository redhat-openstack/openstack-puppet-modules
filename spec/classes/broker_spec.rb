require 'spec_helper'

describe 'kafka::broker' do
  context 'supported operating systems' do
    ['Debian', 'RedHat'].each do |osfamily|

      if osfamily.eql?('RedHat')
        test_os = 'centos'
      else
        test_os = 'ubuntu'
      end

      describe "kafka class without any parameters on #{osfamily}" do
        let(:params) {{ }}
        let(:facts) {{
          :osfamily => osfamily,
          :operatingsystem => test_os,
          :lsbdistcodename => 'lucid'
        }}

        #it { should compile.with_all_deps }

        it { should contain_class('kafka::broker::install').that_comes_before('kafka::broker::config') }
        it { should contain_class('kafka::broker::config') }
        it { should contain_class('kafka::broker::service').that_subscribes_to('kafka::broker::config') }

        it { should contain_class('java') }

        it { should contain_user('kafka') }
        it { should contain_group('kafka') }

        it { should contain_exec('download-kafka-package') }
        it { should contain_exec('untar-kafka-package') }

        it { should contain_file('/usr/local/kafka').with('ensure' => 'link') }

        it { should contain_file('/etc/init.d/kafka') }

        it { should contain_file('/usr/local/kafka/config/server.properties') }
        it { should contain_file('/var/log/kafka').with('ensure' => 'directory') }

        it { should contain_service('kafka') }
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
