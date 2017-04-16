require 'spec_helper'

describe 'ceilometer::policy' do

  shared_examples_for 'ceilometer policies' do
    let :params do
      {
        :policy_path => '/etc/ceilometer/policy.json',
        :policies    => {
          'context_is_admin' => {
            'key'   => 'context_is_admin',
            'value' => 'foo:bar'
          }
        }
      }
    end

    it 'set up the policies' do
      should contain_class('openstacklib::policy').with({
        :policies => params[:policies]
      })
    end
  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    it_configures 'ceilometer policies'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it_configures 'ceilometer policies'
  end
end
