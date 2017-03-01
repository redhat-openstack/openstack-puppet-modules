require 'spec_helper'

describe 'heat::engine' do

  let :default_params do
    { :enabled                       => true,
      :manage_service                => true,
      :heat_stack_user_role          => 'heat_stack_user',
      :heat_metadata_server_url      => 'http://127.0.0.1:8000',
      :heat_waitcondition_server_url => 'http://127.0.0.1:8000/v1/waitcondition',
      :heat_watch_server_url         => 'http://128.0.0.1:8003',
      :engine_life_check_timeout     => '2',
      :trusts_delegated_roles        => ['heat_stack_owner'],
      :deferred_auth_method          => 'trusts',
      :configure_delegated_roles     => true,
    }
  end

  shared_examples_for 'heat-engine' do
    [
      {},
      { :auth_encryption_key           => '1234567890AZERTYUIOPMLKJHGFDSQ' },
      { :auth_encryption_key           => 'foodummybar',
        :enabled                       => false,
        :heat_stack_user_role          => 'heat_stack_user',
        :heat_metadata_server_url      => 'http://127.0.0.1:8000',
        :heat_waitcondition_server_url => 'http://127.0.0.1:8000/v1/waitcondition',
        :heat_watch_server_url         => 'http://128.0.0.1:8003',
        :engine_life_check_timeout     => '2',
        :trusts_delegated_roles        => ['role1', 'role2'],
        :deferred_auth_method          => 'trusts',
        :configure_delegated_roles     => true,
      }
    ].each do |new_params|
      describe 'when #{param_set == {} ? "using default" : "specifying"} parameters'

      let :params do
        new_params
      end

      let :expected_params do
        default_params.merge(params)
      end

      it { is_expected.to contain_package('heat-engine').with_name(os_params[:package_name]) }

      it { is_expected.to contain_service('heat-engine').with(
        :ensure     => (expected_params[:manage_service] && expected_params[:enabled]) ? 'running' : 'stopped',
        :name       => os_params[:service_name],
        :enable     => expected_params[:enabled],
        :hasstatus  => 'true',
        :hasrestart => 'true',
        :require    => [ 'File[/etc/heat/heat.conf]',
                         'Package[heat-common]',
                         'Package[heat-engine]'],
        :subscribe  => 'Exec[heat-dbsync]'
      ) }

      it { is_expected.to contain_heat_config('DEFAULT/auth_encryption_key').with_value( expected_params[:auth_encryption_key] ) }
      it { is_expected.to contain_heat_config('DEFAULT/heat_stack_user_role').with_value( expected_params[:heat_stack_user_role] ) }
      it { is_expected.to contain_heat_config('DEFAULT/heat_metadata_server_url').with_value( expected_params[:heat_metadata_server_url] ) }
      it { is_expected.to contain_heat_config('DEFAULT/heat_waitcondition_server_url').with_value( expected_params[:heat_waitcondition_server_url] ) }
      it { is_expected.to contain_heat_config('DEFAULT/heat_watch_server_url').with_value( expected_params[:heat_watch_server_url] ) }
      it { is_expected.to contain_heat_config('DEFAULT/engine_life_check_timeout').with_value( expected_params[:engine_life_check_timeout] ) }
      it { is_expected.to contain_heat_config('DEFAULT/trusts_delegated_roles').with_value( expected_params[:trusts_delegated_roles] ) }
      it { is_expected.to contain_heat_config('DEFAULT/deferred_auth_method').with_value( expected_params[:deferred_auth_method] ) }

      it 'configures delegated roles' do
        is_expected.to contain_keystone_role("role1").with(
          :ensure  => 'present'
        )
        is_expected.to contain_keystone_role("role2").with(
          :ensure  => 'present'
        )
      end
    end

    context 'stack-abandon enabled' do
      before do
        params.merge!(
          :enable_stack_abandon => true,
        )
      end

      it { is_expected.to contain_heat_config('DEFAULT/enable_stack_abandon').with_value(true) }
    end

    context 'stack-abandon disabled' do
      before do
        params.merge!(
          :enable_stack_abandon => false,
        )
      end

      it { is_expected.to contain_heat_config('DEFAULT/enable_stack_abandon').with_value(false) }
    end


    context 'with disabled service managing' do
      before do
        params.merge!({
          :manage_service => false,
          :enabled        => false })
      end

      it { is_expected.to contain_service('heat-engine').with(
        :ensure     => nil,
        :name       => os_params[:service_name],
        :enable     => false,
        :hasstatus  => 'true',
        :hasrestart => 'true',
        :require    => [ 'File[/etc/heat/heat.conf]',
                         'Package[heat-common]',
                         'Package[heat-engine]'],
        :subscribe  => 'Exec[heat-dbsync]'
      ) }
    end
  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    let :os_params do
      { :package_name => 'heat-engine',
        :service_name => 'heat-engine'
      }
    end

    it_configures 'heat-engine'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    let :os_params do
      { :package_name => 'openstack-heat-engine',
        :service_name => 'openstack-heat-engine'
      }
    end

    it_configures 'heat-engine'
  end
end
