require 'spec_helper'

describe 'aodh::notifier' do

  let :pre_condition do
    "class { '::aodh': }"
  end

  shared_examples_for 'aodh-notifier' do

    context 'when enabled' do
      it { is_expected.to contain_class('aodh::params') }

      it 'installs aodh-notifier package' do
        is_expected.to contain_package(platform_params[:notifier_package_name]).with(
          :ensure => 'present',
          :tag    => ['openstack', 'aodh-package']
        )
      end

      it 'configures aodh-notifier service' do
        is_expected.to contain_service('aodh-notifier').with(
          :ensure     => 'running',
          :name       => platform_params[:notifier_service_name],
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
      it 'configures aodh-notifier service' do
        is_expected.to contain_service('aodh-notifier').with(
          :ensure     => 'stopped',
          :name       => platform_params[:notifier_service_name],
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

      it 'configures aodh-notifier service' do
        is_expected.to contain_service('aodh-notifier').with(
          :ensure     => nil,
          :name       => platform_params[:notifier_service_name],
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
          { :notifier_package_name => 'aodh-notifier',
            :notifier_service_name => 'aodh-notifier' }
        when 'RedHat'
          { :notifier_package_name => 'openstack-aodh-notifier',
            :notifier_service_name => 'openstack-aodh-notifier' }
        end
      end
      it_configures 'aodh-notifier'
    end
  end

end
