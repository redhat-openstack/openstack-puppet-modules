#
# Unit tests for tuskar::client
#
require 'spec_helper'

describe 'tuskar::client' do

  shared_examples_for 'tuskar client' do

    context 'with default parameters' do
      it { is_expected.to contain_package('python-tuskarclient').with_ensure('present') }
    end

    context 'with package_ensure parameter provided' do
      let :params do
        { :package_ensure => false }
      end
      it { is_expected.to contain_package('python-tuskarclient').with_ensure('false') }
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    it_configures 'tuskar client'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it_configures 'tuskar client'
  end
end
