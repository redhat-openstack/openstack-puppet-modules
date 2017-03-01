#
# Unit tests for gnocchi::storage::file
#
require 'spec_helper'

describe 'gnocchi::storage::file' do

  let :params do
    {}
  end

  shared_examples 'gnocchi storage file' do

    context 'with default parameters' do
      it 'configures gnocchi-api with default parameters' do
        is_expected.to contain_gnocchi_config('storage/driver').with_value('file')
        is_expected.to contain_gnocchi_config('storage/file_basepath').with_value('/var/lib/gnocchi')
      end
    end
  end

  context 'on Debian platforms' do
    let :facts do
      {
        :osfamily       => 'Debian'
      }
    end

    it_configures 'gnocchi storage file'
  end

  context 'on RedHat platforms' do
    let :facts do
      {
        :osfamily       => 'RedHat'
      }
    end

    it_configures 'gnocchi storage file'
  end

end
