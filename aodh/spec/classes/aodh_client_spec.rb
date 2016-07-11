require 'spec_helper'

describe 'aodh::client' do

  shared_examples_for 'aodh client' do

    it { is_expected.to contain_class('aodh::params') }

    it 'installs aodh client package' do
      is_expected.to contain_package('python-aodhclient').with(
        :ensure => 'present',
        :name   => 'python-aodhclient',
        :tag    => 'openstack',
      )
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_configures 'aodh client'
    end
  end

end
