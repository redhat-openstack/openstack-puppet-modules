#
# Unit tests for tuskar::init
#
require 'spec_helper'

describe 'tuskar' do

  shared_examples_for 'tuskar' do
    it {
      is_expected.to contain_class('tuskar::params')
      is_expected.to contain_exec('post-tuskar_config')
    }
  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    it_configures 'tuskar'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it_configures 'tuskar'
  end
end
