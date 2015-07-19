require 'spec_helper'
describe 'cassandra::opscenter::pycrypto' do
  context 'Test for cassandra::opscenter::pycrypto on Red Hat.' do
    let :facts do
      {
        :osfamily => 'RedHat'
      }
    end

    it {should contain_class('cassandra::opscenter::pycrypto').with_package_name('pycrypto') }
    it { should contain_class('cassandra::opscenter::pycrypto').with_ensure('present') }
    it { should contain_class('cassandra::opscenter::pycrypto').with_manage_epel('false') }
    it { should contain_class('cassandra::opscenter::pycrypto').with_provider('pip') }
    it { should contain_package('pycrypto') }
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
