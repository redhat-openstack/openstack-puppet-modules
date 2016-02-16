require 'spec_helper'

describe 'aodh::db::postgresql' do

  let :req_params do
    { :password => 'pw' }
  end

  let :pre_condition do
    'include postgresql::server'
  end

  shared_examples 'aodh::db::postgresql' do
    context 'with only required parameters' do
      let :params do
        req_params
      end

      it { is_expected.to contain_postgresql__server__db('aodh').with(
        :user     => 'aodh',
        :password => 'md534e5dd092d680f3d8c11c62951fb5c19'
      )}
    end

  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts({
          :concat_basedir => '/var/lib/puppet/concat'
        }))
      end

      it_configures 'aodh::db::postgresql'
    end
  end


end
