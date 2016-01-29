require 'spec_helper'

describe 'aodh::listener' do

  let :pre_condition do
    "class { '::aodh': }"
  end

  shared_examples_for 'aodh-listener' do

    context 'when enabled' do
      it { is_expected.to contain_class('aodh::params') }

      it 'installs aodh-listener package' do
        is_expected.to contain_package(platform_params[:listener_package_name]).with(
          :ensure => 'present',
          :tag    => ['openstack', 'aodh-package']
        )
      end

      it 'configures aodh-listener service' do
        is_expected.to contain_service('aodh-listener').with(
          :ensure     => 'running',
          :name       => platform_params[:listener_service_name],
          :enable     => true,
          :hasstatus  => true,
          :hasrestart => true,
          :tag        => 'aodh-service',
        )
      end

    end

    context 'when disabled' do
      let :params do
        { :enabled => false }
      end

      # Catalog compilation does not crash for lack of aodh::db
      it { is_expected.to compile }
      it 'configures aodh-listener service' do
        is_expected.to contain_service('aodh-listener').with(
          :ensure     => 'stopped',
          :name       => platform_params[:listener_service_name],
          :enable     => false,
          :hasstatus  => true,
          :hasrestart => true,
          :tag        => 'aodh-service',
        )
      end
    end

    context 'when service management is disabled' do
      let :params do
        { :enabled        => false,
          :manage_service => false }
      end

      it 'configures aodh-listener service' do
        is_expected.to contain_service('aodh-listener').with(
          :ensure     => nil,
          :name       => platform_params[:listener_service_name],
          :enable     => false,
          :hasstatus  => true,
          :hasrestart => true,
          :tag        => 'aodh-service',
        )
      end
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      let(:platform_params) do
        case facts[:osfamily]
        when 'Debian'
          { :listener_package_name => 'aodh-listener',
            :listener_service_name => 'aodh-listener' }
        when 'RedHat'
          { :listener_package_name => 'openstack-aodh-listener',
            :listener_service_name => 'openstack-aodh-listener' }
        end
      end
      it_configures 'aodh-listener'
    end
  end


end
