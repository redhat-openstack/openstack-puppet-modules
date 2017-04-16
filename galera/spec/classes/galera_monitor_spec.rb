require 'spec_helper'
describe 'galera::monitor' do

  let :facts do
    { :osfamily => 'RedHat' }
  end

  let :params do
    {
      :mysql_username    => 'monitor_user',
      :mysql_password    => 'monitor_pass',
      :mysql_host        => '127.0.0.1',
      :mysql_port        => '3306',
      :monitor_port      => '9200',
      :monitor_script    => '/usr/bin/clustercheck',
      :enabled           => true,
      :create_mysql_user => false,
    }
  end

  context 'with galera-monitor xinetd service' do
    context 'with enabled parameter to true' do
      it 'Configures galera-monitor xinetd service' do 
        should contain_xinetd__service('galera-monitor').with(
          :disable                 => 'no',
          :port                    => '9200',
          :server                  => '/usr/bin/clustercheck',
          :flags                   => 'REUSE',
          :per_source              => 'UNLIMITED',
          :service_type            => 'UNLISTED',
          :log_on_success          => '',
          :log_on_success_operator => '=',
          :log_on_failure          => 'HOST',
          :log_on_failure_operator => '=',
        )
      end
    end

    context 'with enabled parameter to false' do
      let(:params) { {:enabled => false } }
      it 'Configures galera-monitor xinetd service' do 
        should contain_xinetd__service('galera-monitor').with(
          :disable                 => 'yes',
          :port                    => '9200',
          :server                  => '/usr/bin/clustercheck',
          :flags                   => 'REUSE',
          :per_source              => 'UNLIMITED',
          :service_type            => 'UNLISTED',
          :log_on_success          => '',
          :log_on_success_operator => '=',
          :log_on_failure          => 'HOST',
          :log_on_failure_operator => '=',
        )
      end
    end
  end

  it 'Configures clustercheck configuration file' do 
    should contain_file('/etc/sysconfig/clustercheck').with(
      :mode  => '0640',
      :owner => 'root',
      :group => 'root',
    )
  end

  context 'with create_mysql_user parameter' do
    let(:params) { {:create_mysql_user => false} }
    context 'create_mysql_user to false' do
      it 'Should not contain mysql_user resource' do
          should_not contain_mysql_user()
      end
    end

    let(:params) { {:create_mysql_user => true} }
    context 'create_mysql_user to true' do
      it 'Should contain mysql_user resource' do
          should contain_mysql_user("monitor_user@127.0.0.1")
      end
    end
  end
end
