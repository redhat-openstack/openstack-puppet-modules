require 'spec_helper'

describe 'manila::share' do

  shared_examples_for 'manila-share' do
    let :pre_condition do
      'class { "manila": rabbit_password => "fpp", sql_connection => "mysql://a:b@c/d" }'
    end

    it { is_expected.to contain_package('manila-share').with(
      :name   => platform_params[:package_name],
      :ensure => 'present'
    ) }
    it { is_expected.to contain_service('manila-share').with(
      'hasstatus' => true
    )}

    describe 'with manage_service false' do
      let :params do
        { 'manage_service' => false }
      end
      it 'should not change the state of the service' do
        is_expected.to contain_service('manila-share').without_ensure
      end
    end
  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    let :platform_params do
      { :package_name => 'manila-share' }
    end

    it_configures 'manila-share'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    let :platform_params do
      { :package_name => 'openstack-manila-share' }
    end

    it_configures 'manila-share'
  end

end
