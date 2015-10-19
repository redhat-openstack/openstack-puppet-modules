#
# Unit tests for aodh::keystone::auth
#

require 'spec_helper'

describe 'aodh::keystone::auth' do

  let :facts do
    { :osfamily => 'Debian' }
  end

  describe 'with default class parameters' do
    let :params do
      { :password => 'aodh_password',
        :tenant   => 'foobar' }
    end

    it { is_expected.to contain_keystone_user('aodh').with(
      :ensure   => 'present',
      :password => 'aodh_password',
      :tenant   => 'foobar'
    ) }

    it { is_expected.to contain_keystone_user_role('aodh@foobar').with(
      :ensure  => 'present',
      :roles   => ['admin']
    )}

    it { is_expected.to contain_keystone_service('aodh').with(
      :ensure      => 'present',
      :type        => 'alarming',
      :description => 'OpenStack Alarming Service'
    ) }

    it { is_expected.to contain_keystone_endpoint('RegionOne/aodh').with(
      :ensure       => 'present',
      :public_url   => 'http://127.0.0.1:8042',
      :admin_url    => 'http://127.0.0.1:8042',
      :internal_url => 'http://127.0.0.1:8042',
    ) }
  end

  describe 'when overriding URL parameters' do
    let :params do
      { :password     => 'aodh_password',
        :public_url   => 'https://10.10.10.10:80',
        :internal_url => 'http://10.10.10.11:81',
        :admin_url    => 'http://10.10.10.12:81' }
    end

    it { is_expected.to contain_keystone_endpoint('RegionOne/aodh').with(
      :ensure       => 'present',
      :public_url   => 'https://10.10.10.10:80',
      :internal_url => 'http://10.10.10.11:81',
      :admin_url    => 'http://10.10.10.12:81'
    ) }
  end

  describe 'when overriding auth name' do
    let :params do
      { :password => 'foo',
        :auth_name => 'aodhany' }
    end

    it { is_expected.to contain_keystone_user('aodhany') }
    it { is_expected.to contain_keystone_user_role('aodhany@services') }
    it { is_expected.to contain_keystone_service('aodhany') }
    it { is_expected.to contain_keystone_endpoint('RegionOne/aodhany') }
  end

  describe 'when overriding service name' do
    let :params do
      { :service_name => 'aodh_service',
        :auth_name    => 'aodh',
        :password     => 'aodh_password' }
    end

    it { is_expected.to contain_keystone_user('aodh') }
    it { is_expected.to contain_keystone_user_role('aodh@services') }
    it { is_expected.to contain_keystone_service('aodh_service') }
    it { is_expected.to contain_keystone_endpoint('RegionOne/aodh_service') }
  end

  describe 'when disabling user configuration' do

    let :params do
      {
        :password       => 'aodh_password',
        :configure_user => false
      }
    end

    it { is_expected.not_to contain_keystone_user('aodh') }
    it { is_expected.to contain_keystone_user_role('aodh@services') }
    it { is_expected.to contain_keystone_service('aodh').with(
      :ensure      => 'present',
      :type        => 'alarming',
      :description => 'OpenStack Alarming Service'
    ) }

  end

  describe 'when disabling user and user role configuration' do

    let :params do
      {
        :password            => 'aodh_password',
        :configure_user      => false,
        :configure_user_role => false
      }
    end

    it { is_expected.not_to contain_keystone_user('aodh') }
    it { is_expected.not_to contain_keystone_user_role('aodh@services') }
    it { is_expected.to contain_keystone_service('aodh').with(
      :ensure      => 'present',
      :type        => 'alarming',
      :description => 'OpenStack Alarming Service'
    ) }

  end

end
