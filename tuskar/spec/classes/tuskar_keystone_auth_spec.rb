#
# Unit tests for tuskar::keystone::auth
#
require 'spec_helper'

describe 'tuskar::keystone::auth' do

  let :facts do
    { :osfamily => 'Debian' }
  end

  describe 'with default class parameters' do
    let :params do
      { :password => 'tuskar_password',
        :tenant   => 'foobar' }
    end

    it { is_expected.to contain_keystone_user('tuskar').with(
      :ensure   => 'present',
      :password => 'tuskar_password',
      :tenant   => 'foobar'
    ) }

    it { is_expected.to contain_keystone_user_role('tuskar@foobar').with(
      :ensure  => 'present',
      :roles   => 'admin'
    )}

    it { is_expected.to contain_keystone_service('tuskar').with(
      :ensure      => 'present',
      :type        => 'management',
      :description => 'Tuskar Management Service'
    ) }

    it { is_expected.to contain_keystone_endpoint('RegionOne/tuskar').with(
      :ensure       => 'present',
      :public_url   => "http://127.0.0.1:8585",
      :admin_url    => "http://127.0.0.1:8585",
      :internal_url => "http://127.0.0.1:8585"
    ) }
  end

  describe 'when configuring tuskar-server' do
    let :pre_condition do
      "class { 'tuskar::server': auth_password => 'test' }"
    end

    let :params do
      { :password => 'tuskar_password',
        :tenant   => 'foobar' }
    end
  end

  describe 'when overriding public_protocol, public_port and public address' do
    let :params do
      { :password         => 'tuskar_password',
        :public_protocol  => 'https',
        :public_port      => '80',
        :public_address   => '10.10.10.10',
        :port             => '81',
        :internal_address => '10.10.10.11',
        :admin_address    => '10.10.10.12' }
    end

    it { is_expected.to contain_keystone_endpoint('RegionOne/tuskar').with(
      :ensure       => 'present',
      :public_url   => "https://10.10.10.10:80",
      :internal_url => "http://10.10.10.11:81",
      :admin_url    => "http://10.10.10.12:81"
    ) }
  end

  describe 'when overriding auth name' do
    let :params do
      { :password => 'foo',
        :auth_name => 'tuskary' }
    end

    it { is_expected.to contain_keystone_user('tuskary') }
    it { is_expected.to contain_keystone_user_role('tuskary@services') }
    it { is_expected.to contain_keystone_service('tuskary') }
    it { is_expected.to contain_keystone_endpoint('RegionOne/tuskary') }
  end
end
