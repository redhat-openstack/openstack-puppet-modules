#
# Unit tests for gnocchi::keystone::auth
#

require 'spec_helper'

describe 'gnocchi::keystone::auth' do

  let :facts do
    { :osfamily => 'Debian' }
  end

  describe 'with default class parameters' do
    let :params do
      { :password => 'gnocchi_password',
        :tenant   => 'foobar' }
    end

    it { is_expected.to contain_keystone_user('gnocchi').with(
      :ensure   => 'present',
      :password => 'gnocchi_password',
    ) }

    it { is_expected.to contain_keystone_user_role('gnocchi@foobar').with(
      :ensure  => 'present',
      :roles   => ['admin']
    )}

    it { is_expected.to contain_keystone_service('gnocchi').with(
      :ensure      => 'present',
      :type        => 'metric',
      :description => 'OpenStack Metric Service'
    ) }

    it { is_expected.to contain_keystone_endpoint('RegionOne/gnocchi').with(
      :ensure       => 'present',
      :public_url   => 'http://127.0.0.1:8041',
      :admin_url    => 'http://127.0.0.1:8041',
      :internal_url => 'http://127.0.0.1:8041',
    ) }
  end

  describe 'when overriding URL parameters' do
    let :params do
      { :password     => 'gnocchi_password',
        :public_url   => 'https://10.10.10.10:80',
        :internal_url => 'http://10.10.10.11:81',
        :admin_url    => 'http://10.10.10.12:81' }
    end

    it { is_expected.to contain_keystone_endpoint('RegionOne/gnocchi').with(
      :ensure       => 'present',
      :public_url   => 'https://10.10.10.10:80',
      :internal_url => 'http://10.10.10.11:81',
      :admin_url    => 'http://10.10.10.12:81'
    ) }
  end

  describe 'when overriding auth name' do
    let :params do
      { :password => 'foo',
        :auth_name => 'gnocchiany' }
    end

    it { is_expected.to contain_keystone_user('gnocchiany') }
    it { is_expected.to contain_keystone_user_role('gnocchiany@services') }
    it { is_expected.to contain_keystone_service('gnocchiany') }
    it { is_expected.to contain_keystone_endpoint('RegionOne/gnocchiany') }
  end

  describe 'when overriding service name' do
    let :params do
      { :service_name => 'gnocchi_service',
        :auth_name    => 'gnocchi',
        :password     => 'gnocchi_password' }
    end

    it { is_expected.to contain_keystone_user('gnocchi') }
    it { is_expected.to contain_keystone_user_role('gnocchi@services') }
    it { is_expected.to contain_keystone_service('gnocchi_service') }
    it { is_expected.to contain_keystone_endpoint('RegionOne/gnocchi_service') }
  end

  describe 'when disabling user configuration' do

    let :params do
      {
        :password       => 'gnocchi_password',
        :configure_user => false
      }
    end

    it { is_expected.not_to contain_keystone_user('gnocchi') }
    it { is_expected.to contain_keystone_user_role('gnocchi@services') }
    it { is_expected.to contain_keystone_service('gnocchi').with(
      :ensure      => 'present',
      :type        => 'metric',
      :description => 'OpenStack Metric Service'
    ) }

  end

  describe 'when disabling user and user role configuration' do

    let :params do
      {
        :password            => 'gnocchi_password',
        :configure_user      => false,
        :configure_user_role => false
      }
    end

    it { is_expected.not_to contain_keystone_user('gnocchi') }
    it { is_expected.not_to contain_keystone_user_role('gnocchi@services') }
    it { is_expected.to contain_keystone_service('gnocchi').with(
      :ensure      => 'present',
      :type        => 'metric',
      :description => 'OpenStack Metric Service'
    ) }

  end

end
