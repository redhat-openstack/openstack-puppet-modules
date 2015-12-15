require 'spec_helper'
# LP1492636 - Cohabitation of compile matcher and webmock
WebMock.disable_net_connect!(:allow => "169.254.169.254")

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

  context 'on Debian platforms' do
    let :facts do
      @default_facts.merge({ :osfamily => 'Debian' })
    end

    let :platform_params do
      { :notifier_package_name => 'aodh-notifier',
        :notifier_service_name => 'aodh-notifier' }
    end

    it_configures 'aodh-notifier'
  end

  context 'on RedHat platforms' do
    let :facts do
      @default_facts.merge({ :osfamily => 'RedHat' })
    end

    let :platform_params do
      { :notifier_package_name => 'openstack-aodh-notifier',
        :notifier_service_name => 'openstack-aodh-notifier' }
    end

    it_configures 'aodh-notifier'
  end
end
