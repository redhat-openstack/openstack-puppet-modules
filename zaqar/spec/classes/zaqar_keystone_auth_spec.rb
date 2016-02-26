#
# Unit tests for zaqar::keystone::auth
#

require 'spec_helper'

describe 'zaqar::keystone::auth' do


  shared_examples_for 'zaqar::keystone::auth' do
    describe 'with default class parameters' do
      let :params do
        { :password => 'zaqar_password',
          :tenant   => 'foobar' }
      end

      it { is_expected.to contain_keystone_user('zaqar').with(
        :ensure   => 'present',
        :password => 'zaqar_password',
      ) }

      it { is_expected.to contain_keystone_user_role('zaqar@foobar').with(
        :ensure  => 'present',
        :roles   => ['admin']
      )}

      it { is_expected.to contain_keystone_service('zaqar::messaging').with(
        :ensure      => 'present',
        :description => 'Openstack messaging Service'
      ) }

      it { is_expected.to contain_keystone_endpoint('RegionOne/zaqar::messaging').with(
        :ensure       => 'present',
        :public_url   => "http://127.0.0.1:8888",
        :admin_url    => "http://127.0.0.1:8888",
        :internal_url => "http://127.0.0.1:8888"
      ) }
    end

    describe 'when overriding public_url, internal_url and admin_url' do
      let :params do
        { :password     => 'zaqar_password',
          :public_url   => 'https://10.10.10.10:8080',
          :admin_url    => 'http://10.10.10.10:8080',
          :internal_url => 'http://10.10.10.10:8080'
        }
      end

      it { is_expected.to contain_keystone_endpoint('RegionOne/zaqar::messaging').with(
        :ensure       => 'present',
        :public_url   => "https://10.10.10.10:8080",
        :internal_url => "http://10.10.10.10:8080",
        :admin_url    => "http://10.10.10.10:8080"
      ) }
    end

    describe 'when overriding auth name' do
      let :params do
        { :password => 'foo',
          :auth_name => 'zaqary' }
      end

      it { is_expected.to contain_keystone_user('zaqary') }
      it { is_expected.to contain_keystone_user_role('zaqary@services') }
      it { is_expected.to contain_keystone_service('zaqary::messaging') }
      it { is_expected.to contain_keystone_endpoint('RegionOne/zaqary::messaging') }
    end

    describe 'when overriding service name' do
      let :params do
        { :service_name => 'zaqar_service',
          :auth_name    => 'zaqar',
          :password     => 'zaqar_password' }
      end

      it { is_expected.to contain_keystone_user('zaqar') }
      it { is_expected.to contain_keystone_user_role('zaqar@services') }
      it { is_expected.to contain_keystone_service('zaqar_service::messaging') }
      it { is_expected.to contain_keystone_endpoint('RegionOne/zaqar_service::messaging') }
    end

    describe 'when disabling user configuration' do

      let :params do
        {
          :password       => 'zaqar_password',
          :configure_user => false
        }
      end

      it { is_expected.not_to contain_keystone_user('zaqar') }
      it { is_expected.to contain_keystone_user_role('zaqar@services') }
      it { is_expected.to contain_keystone_service('zaqar::messaging').with(
        :ensure      => 'present',
        :description => 'Openstack messaging Service'
      ) }

    end

    describe 'when disabling user and user role configuration' do

      let :params do
        {
          :password            => 'zaqar_password',
          :configure_user      => false,
          :configure_user_role => false
        }
      end

      it { is_expected.not_to contain_keystone_user('zaqar') }
      it { is_expected.not_to contain_keystone_user_role('zaqar@services') }
      it { is_expected.to contain_keystone_service('zaqar::messaging').with(
        :ensure      => 'present',
        :description => 'Openstack messaging Service'
      ) }

    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_configures 'zaqar::keystone::auth'
    end
  end

end
