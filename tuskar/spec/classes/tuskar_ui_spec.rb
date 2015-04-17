#
# Unit tests for tuskar::ui
#
require 'spec_helper'

describe 'tuskar::ui' do

  shared_examples_for 'tuskar ui' do

    context 'with default parameters' do
      it 'installs tuskar-ui package' do
        should contain_package('tuskar-ui').with(
          :name   => platform_params[:ui_package_name],
          :ensure => 'present',
        )
        should_not contain_package('tuskar-ui-extras')
      end
    end

    context 'with extras parameter parameter provided' do
      let :params do
        { :extras => true }
      end
      it 'installs tuskar-ui and tuskar-ui-extras packages' do
        should contain_package('tuskar-ui').with(
          :name   => platform_params[:ui_package_name],
          :ensure => 'present',
        )
        should contain_package('tuskar-ui-extras').with(
          :name   => platform_params[:ui_extras_package_name],
          :ensure => 'present',
        )
      end
    end

    context 'with package_ensure parameter provided' do
      let :params do
        { :package_ensure => 'absent' }
      end
      it 'installs tuskar-ui and tuskar-ui-extras packages' do
        should contain_package('tuskar-ui').with(
          :name   => platform_params[:ui_package_name],
          :ensure => 'absent',
        )
      end
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    let :platform_params do
      { :ui_package_name        => 'tuskar-ui',
        :ui_extras_package_name => 'tuskar-ui-extras' }
    end

    it_configures 'tuskar ui'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    let :platform_params do
      { :ui_package_name        => 'openstack-tuskar-ui',
        :ui_extras_package_name => 'openstack-tuskar-ui-extras' }
    end

    it_configures 'tuskar ui'
  end
end
