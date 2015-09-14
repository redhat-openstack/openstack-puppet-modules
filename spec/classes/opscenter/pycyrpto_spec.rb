require 'spec_helper'
describe 'cassandra::opscenter::pycrypto' do
  context 'Test for cassandra::opscenter::pycrypto on Red Hat.' do
    let :facts do
      {
        :osfamily => 'RedHat'
      }
    end

    it { should have_resource_count(4) }
    it {
      should contain_class('cassandra::opscenter::pycrypto').only_with({
        'ensure'       => 'present',
        'manage_epel'  => false,
        'package_name' => 'pycrypto',
        'provider'     => 'pip',
        'reqd_pckgs'   => ['python-devel', 'python-pip'],
      })
    }
    it { should contain_package('pycrypto') }
    it { should contain_file('/usr/bin/pip-python') }
    it { should contain_package('python-devel') }
    it { should contain_package('python-pip') }
  end

  context 'Test for cassandra::opscenter::pycrypto on Debian.' do
    let :facts do
      {
        :osfamily => 'Debian'
      }
    end

    it { should contain_class('cassandra::opscenter::pycrypto') }
    it { should contain_class('cassandra::opscenter::pycrypto').with_package_name('pycrypto') }
    it { should contain_class('cassandra::opscenter::pycrypto').with_ensure('present') }
    it { should contain_class('cassandra::opscenter::pycrypto').with_provider('pip') }
    it { should_not contain_package('pycrypto') }
  end
end
