#
# Unit tests for gnocchi::storage::influxdb
#
require 'spec_helper'

describe 'gnocchi::storage::influxdb' do

  let :params do
    {}
  end

  shared_examples 'gnocchi storage influxdb' do

    context 'with default parameters' do
      it 'configures gnocchi-api with default parameters' do
        is_expected.to contain_gnocchi_config('storage/driver').with_value('influxdb')
        is_expected.to contain_gnocchi_config('storage/influxdb_host').with_value('localhost')
        is_expected.to contain_gnocchi_config('storage/influxdb_port').with_value(8086)
        is_expected.to contain_gnocchi_config('storage/influxdb_database').with_value('gnocchi')
        is_expected.to contain_gnocchi_config('storage/influxdb_username').with_value('root')
      end
    end
  end

  context 'with overridden parameters' do
    let :params do
      { :influxdb_host                      => '127.0.0.1',
        :influxdb_port                      => 80,
        :influxdb_database                  => 'mydb',
        :influxdb_username                  => 'gnocchi',
        :influxdb_password                  => 'private',
        :influxdb_block_until_data_ingested => true,
      }
    end

    it 'configures gnocchi-api with explicit parameters' do
      is_expected.to contain_gnocchi_config('storage/driver').with_value('influxdb')
      is_expected.to contain_gnocchi_config('storage/influxdb_host').with_value('127.0.0.1')
      is_expected.to contain_gnocchi_config('storage/influxdb_port').with_value(80)
      is_expected.to contain_gnocchi_config('storage/influxdb_database').with_value('mydb')
      is_expected.to contain_gnocchi_config('storage/influxdb_username').with_value('gnocchi')
      is_expected.to contain_gnocchi_config('storage/influxdb_password').with_value('private').with_secret(true)
      is_expected.to contain_gnocchi_config('storage/influxdb_block_until_data_ingested').with_value('true')
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'gnocchi storage influxdb'
    end
  end

end
