require 'spec_helper'
describe 'galera::server' do
  let :facts do
    { :osfamily => 'RedHat' }
  end
  let :params do
    {
      :package_name          => 'mariadb-galera-server',
      :package_ensure        => 'present',
      :service_name          => 'mariadb',
      :service_enable        => false,
      :service_ensure        => 'running',
      :wsrep_bind_address    => '0.0.0.0',
      :wsrep_provider        => '/usr/lib64/galera/libgalera_smm.so',
      :wsrep_cluster_name    => 'galera_cluster',
      :wsrep_cluster_address => 'gcomm://',
      :wsrep_sst_method      => 'rsync',
      :wsrep_sst_username    => 'wsrep_user',
      :wsrep_sst_password    => 'wsrep_pass',
    }
  end

  it { should contain_package('galera')}
  it { should contain_file('/etc/my.cnf.d/galera.cnf')}
  it { should contain_service('galera')}

end
