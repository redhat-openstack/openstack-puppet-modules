require 'spec_helper'

describe 'sahara::service::api' do

  shared_examples_for 'sahara-api' do

    context 'require main class' do
      it { is_expected.to contain_class('sahara') }
    end

    context 'default params' do
      it { is_expected.to contain_sahara_config('DEFAULT/api_workers').with_value('0') }
    end

    context 'passing params' do
      let :params do
      {
        :api_workers => '2',
      }
      end

      it { is_expected.to contain_sahara_config('DEFAULT/api_workers').with_value('2') }
    end

  end

  context 'on Debian platforms' do
    let :facts do
      {
        :osfamily => 'Debian',
        :operatingsystem => 'Debian'
      }
    end

    it_configures 'sahara-api'

    it_behaves_like 'generic sahara service', {
       :name         => 'sahara-api',
       :package_name => 'sahara-api',
       :service_name => 'sahara-api' }
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it_configures 'sahara-api'

    it_behaves_like 'generic sahara service', {
       :name         => 'sahara-api',
       :package_name => 'openstack-sahara-api',
       :service_name => 'openstack-sahara-api' }
  end

end
