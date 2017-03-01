require 'spec_helper'

describe 'gnocchi::storage' do

  let :params do
    { :package_ensure => 'latest' }
  end

  shared_examples_for 'gnocchi-storage' do

    it { is_expected.to contain_class('gnocchi::params') }

    it 'installs gnocchi-carbonara package' do
      is_expected.to contain_package('gnocchi-carbonara').with(
        :ensure => 'latest',
        :name   => platform_params[:carbonara_package_name],
        :tag    => ['openstack', 'gnocchi-package'],
      )
    end
  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily               => 'Debian',
        :operatingsystem        => 'Debian' }
    end

    let :platform_params do
      { :carbonara_package_name => 'gnocchi-carbonara' }
    end

    it_configures 'gnocchi-storage'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily        => 'RedHat',
        :operatingsystem => 'RedHat' }
    end

    let :platform_params do
      { :carbonara_package_name => 'openstack-gnocchi-carbonara' }
    end

    it_configures 'gnocchi-storage'
  end
end
