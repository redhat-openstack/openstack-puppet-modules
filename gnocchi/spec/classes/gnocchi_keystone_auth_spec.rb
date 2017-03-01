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
      :tenant   => 'foobar'
    ) }

    it { is_expected.to contain_keystone_user_role('gnocchi@foobar').with(
      :ensure  => 'present',
      :roles   => ['admin']
    )}

    it { is_expected.to contain_keystone_service('gnocchi').with(
      :ensure      => 'present',
      :type        => 'gnocchi',
      :description => 'OpenStack Datapoint Service'
    ) }

    it { is_expected.to contain_keystone_endpoint('RegionOne/gnocchi').with(
      :ensure       => 'present',
      :public_url   => "http://127.0.0.1:8041",
      :admin_url    => "http://127.0.0.1:8041",
      :internal_url => "http://127.0.0.1:8041"
    ) }
  end

  describe 'when overriding public_protocol, public_port and public_address' do
    let :params do
      { :password         => 'gnocchi_password',
        :public_protocol  => 'https',
        :public_port      => '80',
        :public_address   => '10.10.10.10',
        :admin_port       => '81',
        :internal_port    => '82',
        :internal_address => '10.10.10.11',
        :admin_address    => '10.10.10.12' }
    end

    it { is_expected.to contain_keystone_endpoint('RegionOne/gnocchi').with(
      :ensure       => 'present',
      :public_url   => "https://10.10.10.10:80",
      :internal_url => "http://10.10.10.11:82",
      :admin_url    => "http://10.10.10.12:81"
    ) }
  end

  describe 'when overriding auth name' do
    let :params do
      { :password => 'foo',
        :auth_name => 'gnocchy' }
    end

    it { is_expected.to contain_keystone_user('gnocchy') }
    it { is_expected.to contain_keystone_user_role('gnocchy@services') }
    it { is_expected.to contain_keystone_service('gnocchy') }
    it { is_expected.to contain_keystone_endpoint('RegionOne/gnocchy') }
  end
end
