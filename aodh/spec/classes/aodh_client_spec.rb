require 'spec_helper'

describe 'aodh::client' do

  shared_examples_for 'aodh client' do

    it { is_expected.to contain_class('aodh::params') }

    it 'installs aodh client package' do
      is_expected.to contain_package('python-ceilometerclient').with(
        :ensure => 'present',
        :name   => 'python-ceilometerclient',
        :tag    => 'openstack',
      )
    end
  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    it_configures 'aodh client'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it_configures 'aodh client'
  end
end
