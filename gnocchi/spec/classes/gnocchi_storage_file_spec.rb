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

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      let(:platform_params) do
        case facts[:osfamily]
        when 'Debian'
          { :aodh_common_package => 'aodh-common' }
        when 'RedHat'
          { :aodh_common_package => 'openstack-aodh-common' }
        end
      end
      it_behaves_like 'gnocchi storage file'
    end
  end

end
