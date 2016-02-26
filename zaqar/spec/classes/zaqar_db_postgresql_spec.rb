require 'spec_helper'

describe 'zaqar::db::postgresql' do

  shared_examples_for 'zaqar::db::postgresql' do
    let :req_params do
      { :password => 'pw' }
    end

    let :pre_condition do
      'include postgresql::server'
    end

    context 'with only required parameters' do
      let :params do
        req_params
      end

      it { is_expected.to contain_postgresql__server__db('zaqar').with(
        :user     => 'zaqar',
        :password => 'md52e9c9a1a01bb2fef7463b70dd24d4b25'
      )}
    end

  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts({ :concat_basedir => '/var/lib/puppet/concat' }))
      end

      it_configures 'zaqar::db::postgresql'
    end
  end

end
