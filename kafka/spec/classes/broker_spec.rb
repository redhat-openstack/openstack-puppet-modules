require 'spec_helper'

describe 'kafka::broker' do
  context 'supported operating systems' do
    describe "kafka class without any parameters on Debian" do
      let(:params) {{ }}
      let(:facts) {{
        :osfamily => 'Debian',
        :operatingsystem => 'ubuntu',
        :operatingsystemrelease => '14.04',
        :lsbdistcodename => 'lucid',
        :architecture => 'amd64'
      }}

      #it { should compile.with_all_deps }

      it { should contain_class('kafka::broker::install').that_comes_before('kafka::broker::config') }
      it { should contain_class('kafka::broker::config').that_comes_before('kafka::broker::service') }

      it { should contain_class('java') }

      it { should contain_user('kafka') }
      it { should contain_group('kafka') }

      it { should contain_exec('download-kafka-package') }
      it { should contain_exec('untar-kafka-package') }

      it { should contain_file('/opt/kafka').with('ensure' => 'link') }

      it { should contain_file('/etc/init.d/kafka') }

      it { should contain_file('/opt/kafka/config/server.properties').that_notifies('Service[kafka]') }


      it { should contain_file('/var/log/kafka').with('ensure' => 'directory') }

      it { should contain_service('kafka') }
    end

    describe "kafka class without any parameters on RedHat" do
      let(:params) {{ }}
      let(:facts) {{
        :osfamily => 'RedHat',
        :operatingsystem => 'centos',
        :operatingsystemrelease => '6',
        :architecture => 'amd64'
      }}

      #it { should compile.with_all_deps }

      it { should contain_class('kafka::broker::install').that_comes_before('kafka::broker::config') }
      it { should contain_class('kafka::broker::config').that_comes_before('kafka::broker::service') }

      it { should contain_class('java') }

      it { should contain_user('kafka') }
      it { should contain_group('kafka') }

      it { should contain_exec('download-kafka-package') }
      it { should contain_exec('untar-kafka-package') }

      it { should contain_file('/opt/kafka').with('ensure' => 'link') }

      it { should contain_file('/etc/init.d/kafka') }

      it { should contain_file('/opt/kafka/config/server.properties') }
      it { should contain_file('/var/log/kafka').with('ensure' => 'directory') }

      it { should contain_service('kafka') }
    end
  end

  context 'unsupported operating system' do
    describe 'kafka class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
        :architecture    => 'amd64'
      }}

      it { expect { should contain_package('kafka') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
