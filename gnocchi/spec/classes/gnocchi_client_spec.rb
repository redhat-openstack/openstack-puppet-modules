require 'spec_helper'

describe 'gnocchi::client' do

  shared_examples_for 'gnocchi client' do

    it { is_expected.to contain_class('gnocchi::params') }

    it 'installs gnocchi client package' do
      is_expected.to contain_package('python-gnocchiclient').with(
        :ensure => 'present',
        :name   => 'python-gnocchiclient',
        :tag    => 'openstack',
      )
    end
  end

  context 'on Debian platforms' do
    let :facts do
      @default_facts.merge({ :osfamily => 'Debian' })
    end

    it_configures 'gnocchi client'
  end

  context 'on RedHat platforms' do
    let :facts do
      @default_facts.merge({ :osfamily => 'RedHat' })
    end

    it_configures 'gnocchi client'
  end
end
