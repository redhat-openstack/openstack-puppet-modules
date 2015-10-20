require 'spec_helper'
# LP1492636 - Cohabitation of compile matcher and webmock
WebMock.disable_net_connect!(:allow => "169.254.169.254")

describe 'aodh::evaluator' do

  let :pre_condition do
    "class { '::aodh': }"
  end

  let :params do
    { :enabled => true }
  end

  shared_examples_for 'aodh-evaluator' do

    context 'with coordination' do
      before do
        params.merge!({ :coordination_url => 'redis://localhost:6379' })
      end

      it 'configures backend_url' do
        is_expected.to contain_aodh_config('coordination/backend_url').with_value('redis://localhost:6379')
      end
    end

    context 'when enabled' do
      it { is_expected.to contain_class('aodh::params') }

      it 'installs aodh-evaluator package' do
        is_expected.to contain_package(platform_params[:evaluator_package_name]).with(
          :ensure => 'present'
        )
      end

      it 'configures aodh-evaluator service' do
        is_expected.to contain_service('aodh-evaluator').with(
          :ensure     => 'running',
          :name       => platform_params[:evaluator_service_name],
          :enable     => true,
          :hasstatus  => true,
          :hasrestart => true,
          :tag        => ['aodh-service','aodh-db-sync-service']
        )
      end

    end

    context 'when disabled' do
      let :params do
        { :enabled => false }
      end

      # Catalog compilation does not crash for lack of aodh::db
      it { is_expected.to compile }
      it 'configures aodh-evaluator service' do
        is_expected.to contain_service('aodh-evaluator').with(
          :ensure     => 'stopped',
          :name       => platform_params[:evaluator_service_name],
          :enable     => false,
          :hasstatus  => true,
          :hasrestart => true,
          :tag        => ['aodh-service','aodh-db-sync-service']
        )
      end
    end

    context 'when service management is disabled' do
      let :params do
        { :enabled        => false,
          :manage_service => false }
      end

      it 'configures aodh-evaluator service' do
        is_expected.to contain_service('aodh-evaluator').with(
          :ensure     => nil,
          :name       => platform_params[:evaluator_service_name],
          :enable     => false,
          :hasstatus  => true,
          :hasrestart => true,
          :tag        => ['aodh-service','aodh-db-sync-service']
        )
      end
    end
  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    let :platform_params do
      { :evaluator_package_name => 'aodh-evaluator',
        :evaluator_service_name => 'aodh-evaluator' }
    end

    it_configures 'aodh-evaluator'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    let :platform_params do
      { :evaluator_package_name => 'openstack-aodh-evaluator',
        :evaluator_service_name => 'openstack-aodh-evaluator' }
    end

    it_configures 'aodh-evaluator'
  end
end
