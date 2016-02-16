require 'spec_helper'

describe 'gnocchi::metricd' do

  let :params do { }
  end

  shared_examples_for 'gnocchi-metricd' do

    it { is_expected.to contain_class('gnocchi::params') }

    it 'installs gnocchi-metricd package' do
      is_expected.to contain_package('gnocchi-metricd').with(
        :ensure => 'present',
        :name   => platform_params[:metricd_package_name],
        :tag    => ['openstack', 'gnocchi-package'],
      )
    end

    [{:enabled => true}, {:enabled => false}].each do |param_hash|
      context "when service should be #{param_hash[:enabled] ? 'enabled' : 'disabled'}" do
        before do
          params.merge!(param_hash)
        end

        it 'configures gnocchi-metricd service' do
          is_expected.to contain_service('gnocchi-metricd').with(
            :ensure     => params[:enabled] ? 'running' : 'stopped',
            :name       => platform_params[:metricd_service_name],
            :enable     => params[:enabled],
            :hasstatus  => true,
            :hasrestart => true,
            :tag        => ['gnocchi-service', 'gnocchi-db-sync-service'],
          )
        end
      end
    end

    context 'with disabled service managing' do
      before do
        params.merge!({
          :manage_service => false,
          :enabled        => false })
      end

      it 'configures gnocchi-metricd service' do
        is_expected.to contain_service('gnocchi-metricd').with(
          :ensure     => nil,
          :name       => platform_params[:metricd_service_name],
          :enable     => false,
          :hasstatus  => true,
          :hasrestart => true,
          :tag        => ['gnocchi-service', 'gnocchi-db-sync-service'],
        )
      end
    end
  end

  context 'on Debian platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily        => 'Debian',
        :operatingsystem => 'Debian',
      })
    end

    let :platform_params do
      { :metricd_package_name => 'gnocchi-metricd',
        :metricd_service_name => 'gnocchi-metricd' }
    end

    it_configures 'gnocchi-metricd'
  end

  context 'on RedHat platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily               => 'RedHat',
        :operatingsystem        => 'RedHat',
      })
    end

    let :platform_params do
      { :metricd_package_name => 'openstack-gnocchi-metricd',
        :metricd_service_name => 'openstack-gnocchi-metricd' }
    end

    it_configures 'gnocchi-metricd'
  end

end
