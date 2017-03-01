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
        should contain_gnocchi_config('storage/driver').with_value('swift')
        should contain_gnocchi_config('storage/swift_user').with_value('admin:admin')
        should contain_gnocchi_config('storage/swift_key').with_value('admin')
        should contain_gnocchi_config('storage/swift_authurl').with_value('http://localhost:8080/auth/v1.0')
        should contain_gnocchi_config('storage/swift_auth_version').with_value('1')
      end
    end
  end

  context 'on Debian platforms' do
    let :facts do
      {
        :osfamily       => 'Debian'
      }
    end

    it_configures 'gnocchi storage swift'
  end

  context 'on RedHat platforms' do
    let :facts do
      {
        :osfamily       => 'RedHat'
      }
    end

    it_configures 'gnocchi storage swift'
  end

end
