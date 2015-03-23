#
# Unit tests for gnocchi::storage::ceph
#
require 'spec_helper'

describe 'gnocchi::storage::ceph' do

  let :params do
    {
      :ceph_username => 'joe',
      :ceph_keyring  => 'client.admin',
    }
  end

  shared_examples 'gnocchi storage ceph' do

    context 'with default parameters' do
      it 'configures gnocchi-api with default parameters' do
        is_expected.to contain_gnocchi_config('storage/driver').with_value('ceph')
        is_expected.to contain_gnocchi_config('storage/ceph_username').with_value('joe')
        is_expected.to contain_gnocchi_config('storage/ceph_keyring').with_value('client.admin')
        is_expected.to contain_gnocchi_config('storage/ceph_pool').with_value('gnocchi')
        is_expected.to contain_gnocchi_config('storage/ceph_conffile').with_value('/etc/ceph/ceph.conf')
      end
    end
  end

  context 'on Debian platforms' do
    let :facts do
      {
        :osfamily       => 'Debian'
      }
    end

    it_configures 'gnocchi storage ceph'
  end

  context 'on RedHat platforms' do
    let :facts do
      {
        :osfamily       => 'RedHat'
      }
    end

    it_configures 'gnocchi storage ceph'
  end

end
