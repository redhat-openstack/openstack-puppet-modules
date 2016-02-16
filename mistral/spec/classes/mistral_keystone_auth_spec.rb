#
# Unit tests for mistral::keystone::auth
#

require 'spec_helper'

describe 'mistral::keystone::auth' do

  let :facts do
    { :osfamily => 'Debian' }
  end

  describe 'with default class parameters' do
    let :params do
      { :password => 'mistral_password',
        :tenant   => 'services' }
    end

    it { is_expected.to contain_keystone_user('mistral').with(
      :ensure   => 'present',
      :password => 'mistral_password',
    ) }

    it { is_expected.to contain_keystone_user_role('mistral@services').with(
      :ensure  => 'present',
      :roles   => ['admin']
    )}

    it { is_expected.to contain_keystone_service('mistral::workflowv2').with(
      :ensure      => 'present',
      :description => 'OpenStack Workflow Service'
    ) }

    it { is_expected.to contain_keystone_endpoint('RegionOne/mistral::workflowv2').with(
      :ensure       => 'present',
      :public_url   => "http://127.0.0.1:8989/v2",
      :admin_url    => "http://127.0.0.1:8989/v2",
      :internal_url => "http://127.0.0.1:8989/v2"
    ) }
  end

  describe 'when overriding auth name' do
    let :params do
      { :password => 'foo',
        :auth_name => 'mistraly' }
    end

    it { is_expected.to contain_keystone_user('mistraly') }
    it { is_expected.to contain_keystone_user_role('mistraly@services') }
    it { is_expected.to contain_keystone_service('mistraly::workflowv2') }
    it { is_expected.to contain_keystone_endpoint('RegionOne/mistraly::workflowv2') }
  end

  describe 'when overriding service name' do
    let :params do
      { :service_name => 'mistral_service',
        :auth_name    => 'mistral',
        :password     => 'mistral_password' }
    end

    it { is_expected.to contain_keystone_user('mistral') }
    it { is_expected.to contain_keystone_user_role('mistral@services') }
    it { is_expected.to contain_keystone_service('mistral_service::workflowv2') }
    it { is_expected.to contain_keystone_endpoint('RegionOne/mistral_service::workflowv2') }
  end

  describe 'when disabling user configuration' do

    let :params do
      {
        :password       => 'mistral_password',
        :configure_user => false
      }
    end

    it { is_expected.not_to contain_keystone_user('mistral') }
    it { is_expected.to contain_keystone_user_role('mistral@services') }
    it { is_expected.to contain_keystone_service('mistral::workflowv2').with(
      :ensure      => 'present',
      :description => 'OpenStack Workflow Service'
    ) }

  end

  describe 'when disabling user and user role configuration' do

    let :params do
      {
        :password            => 'mistral_password',
        :configure_user      => false,
        :configure_user_role => false
      }
    end

    it { is_expected.not_to contain_keystone_user('mistral') }
    it { is_expected.not_to contain_keystone_user_role('mistral@services') }
    it { is_expected.to contain_keystone_service('mistral::workflowv2').with(
      :ensure      => 'present',
      :description => 'OpenStack Workflow Service'
    ) }

  end

end
