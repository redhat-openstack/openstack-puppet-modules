require 'spec_helper'

describe 'gnocchi' do

  shared_examples 'gnocchi' do

    context 'with default parameters' do
     it 'contains the logging class' do
       is_expected.to contain_class('gnocchi::logging')
     end

      it 'installs packages' do
        is_expected.to contain_package('gnocchi').with(
          :name   => platform_params[:gnocchi_common_package],
          :ensure => 'present',
          :tag    => ['openstack', 'gnocchi-package']
        )
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
          { :gnocchi_common_package => 'gnocchi-common' }
        when 'RedHat'
          { :gnocchi_common_package => 'openstack-gnocchi-common' }
        end
      end
      it_behaves_like 'gnocchi'
    end
  end

end
