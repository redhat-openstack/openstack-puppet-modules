require 'spec_helper'
describe 'zaqar' do
  shared_examples 'zaqar' do
    let :req_params do
      {
        :admin_password   => 'foo',
      }
    end

    describe 'with only required params' do
      let :params do
        req_params
      end

      it { is_expected.to contain_package('zaqar-common').with(
          :ensure => 'present',
          :name   => platform_params[:zaqar_common_package],
          :tag    => ['openstack', 'zaqar-package']
      )}

      it { is_expected.to contain_class('zaqar::params') }

      it 'should contain default config' do
        is_expected.to contain_zaqar_config('keystone_authtoken/auth_uri').with(
         :value => 'http://localhost:5000/'
        )
        is_expected.to contain_zaqar_config('keystone_authtoken/identity_uri').with(
         :value => 'http://localhost:35357/'
        )
        is_expected.to contain_zaqar_config('keystone_authtoken/admin_tenant_name').with(
         :value => 'services'
        )
        is_expected.to contain_zaqar_config('keystone_authtoken/admin_user').with(
         :value => 'zaqar'
        )
        is_expected.to contain_zaqar_config('keystone_authtoken/admin_password').with(
         :value => 'foo'
        )
        is_expected.to contain_zaqar_config('DEFAULT/auth_strategy').with(
         :value => 'keystone'
        )
      end

    end

    describe 'with custom values' do
      let :params do
        req_params.merge!({
          :admin_mode  => true,
          :unreliable  => true,
          :pooling  => true
        })
      end

      it do
        is_expected.to contain_zaqar_config('DEFAULT/admin_mode').with_value(true)
        is_expected.to contain_zaqar_config('DEFAULT/unreliable').with_value(true)
        is_expected.to contain_zaqar_config('DEFAULT/pooling').with_value(true)
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
          { :zaqar_common_package => 'zaqar' }
        when 'RedHat'
          { :zaqar_common_package => 'openstack-zaqar' }
        end
      end
      it_behaves_like 'zaqar'
    end
  end
end
