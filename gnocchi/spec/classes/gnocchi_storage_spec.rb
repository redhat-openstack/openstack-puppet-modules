require 'spec_helper'

describe 'gnocchi::storage' do

  let :params do
    { :package_ensure => 'latest' }
  end

  shared_examples_for 'gnocchi-storage' do

    it { is_expected.to contain_class('gnocchi::params') }

    it 'installs gnocchi-carbonara package' do
      is_expected.to contain_package('gnocchi-carbonara').with(
        :ensure => 'latest',
        :name   => platform_params[:carbonara_package_name],
        :tag    => ['openstack', 'gnocchi-package'],
      )
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
          { :carbonara_package_name => 'gnocchi-carbonara' }
        when 'RedHat'
          { :carbonara_package_name => 'openstack-gnocchi-carbonara' }
        end
      end
      it_behaves_like 'gnocchi-storage'
    end
  end

end
