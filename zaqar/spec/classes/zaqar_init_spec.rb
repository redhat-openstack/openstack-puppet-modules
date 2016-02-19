require 'spec_helper'
describe 'zaqar' do
  let :req_params do
    {
      :admin_password   => 'foo',
    }
  end

  let :facts do
    { :osfamily => 'RedHat' }
  end

  describe 'with only required params' do
    let :params do
      req_params
    end

    it { is_expected.to contain_package('zaqar-common').with(
        :ensure => 'present',
        :name   => 'openstack-zaqar'
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
