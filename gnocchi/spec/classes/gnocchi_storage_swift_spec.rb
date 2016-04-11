#
# Unit tests for gnocchi::storage::swift
#
require 'spec_helper'

describe 'gnocchi::storage::swift' do

  let :params do
    {}
  end

  shared_examples 'gnocchi storage swift' do

    context 'with default parameters' do
      it 'configures gnocchi-api with default parameters' do
        is_expected.to contain_gnocchi_config('storage/driver').with_value('swift')
        is_expected.to contain_gnocchi_config('storage/swift_user').with_value('admin:admin')
        is_expected.to contain_gnocchi_config('storage/swift_key').with_value('admin')
        is_expected.to contain_gnocchi_config('storage/swift_authurl').with_value('http://localhost:8080/auth/v1.0')
        is_expected.to contain_gnocchi_config('storage/swift_auth_version').with_value('1')
      end
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'gnocchi storage swift'
    end
  end
end
