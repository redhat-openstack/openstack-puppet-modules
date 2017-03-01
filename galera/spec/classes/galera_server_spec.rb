require 'spec_helper'

describe 'galera::server', :type => :class do

  let :facts do
    { :osfamily => 'RedHat' }
  end

  let :params do
    {
      :bootstrap             => false,
      :debug                 => false,
      :service_name          => 'mariadb',
      :service_enable        => true,
      :service_ensure        => 'running',
      :manage_service        => false,
      :wsrep_bind_address    => '0.0.0.0',
      :wsrep_node_address    => 'undef',
      :wsrep_provider        => '/usr/lib64/galera/libgalera_smm.so',
      :wsrep_cluster_name    => 'galera_cluster',
      :wsrep_cluster_members => ['127.0.0.1'],
      :wsrep_sst_method      => 'rsync',
      :wsrep_sst_username    => 'root',
      :wsrep_sst_password    => 'undef',
      :wsrep_ssl             => false,
      :wsrep_ssl_key         => 'undef',
      :wsrep_ssl_cert        => 'undef',
    }
  end

  it { should contain_class('mysql::server') }

  context 'Configures /etc/my.cnf.d/galera.cnf' do
    it { should contain_file('/etc/my.cnf.d/galera.cnf').with(
      'ensure' => 'present',
      'mode'   => '0644',
      'owner'  => 'root',
      'group'  => 'root',
      'notify' => 'Service[mariadb]'
      )
    }
  end

  context 'with manage_service to false' do
    it "Doesn't configure galera service" do
      should_not contain_service('galera')
    end
  end

  context 'with manage_service to true' do
    let(:params) { {:manage_service => true} }
    it "Configures galera service" do
      should contain_service('galera').with(
        'ensure' => 'running',
        'name'   => 'mariadb',
        'enable' => 'true',
      )
    end
  end
end
