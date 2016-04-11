require 'spec_helper'

describe 'gnocchi::statsd' do

  let :params do
    { :enabled             => true,
      :manage_service      => true,
      :resource_id         => '07f26121-5777-48ba-8a0b-d70468133dd9',
      :user_id             => '07f26121-5777-48ba-8a0b-d70468133dd9',
      :project_id          => '07f26121-5777-48ba-8a0b-d70468133dd9',
      :archive_policy_name => 'high',
      :flush_delay         => '200',
    }
  end

  shared_examples_for 'gnocchi-statsd' do

    it { is_expected.to contain_class('gnocchi::params') }

    it 'installs gnocchi-statsd package' do
      is_expected.to contain_package('gnocchi-statsd').with(
        :ensure => 'present',
        :name   => platform_params[:statsd_package_name],
        :tag    => ['openstack', 'gnocchi-package'],
      )
    end

    it 'configures gnocchi statsd' do
      is_expected.to contain_gnocchi_config('statsd/resource_id').with_value('07f26121-5777-48ba-8a0b-d70468133dd9')
      is_expected.to contain_gnocchi_config('statsd/user_id').with_value('07f26121-5777-48ba-8a0b-d70468133dd9')
      is_expected.to contain_gnocchi_config('statsd/project_id').with_value('07f26121-5777-48ba-8a0b-d70468133dd9')
      is_expected.to contain_gnocchi_config('statsd/archive_policy_name').with_value('high')
      is_expected.to contain_gnocchi_config('statsd/flush_delay').with_value('200')
    end

    [{:enabled => true}, {:enabled => false}].each do |param_hash|
      context "when service should be #{param_hash[:enabled] ? 'enabled' : 'disabled'}" do
        before do
          params.merge!(param_hash)
        end

        it 'configures gnocchi-statsd service' do
          is_expected.to contain_service('gnocchi-statsd').with(
            :ensure     => (params[:manage_service] && params[:enabled]) ? 'running' : 'stopped',
            :name       => platform_params[:statsd_service_name],
            :enable     => params[:enabled],
            :hasstatus  => true,
            :hasrestart => true,
            :tag        => ['gnocchi-service', 'gnocchi-db-sync-service'],
          )
        end
      end
    end

    context 'with disabled service managing' do
      before do
        params.merge!({
          :manage_service => false,
          :enabled        => false })
      end

      it 'configures gnocchi-statsd service' do
        is_expected.to contain_service('gnocchi-statsd').with(
          :ensure     => nil,
          :name       => platform_params[:statsd_service_name],
          :enable     => false,
          :hasstatus  => true,
          :hasrestart => true,
          :tag        => ['gnocchi-service', 'gnocchi-db-sync-service'],
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
          { :statsd_package_name => 'gnocchi-statsd',
            :statsd_service_name => 'gnocchi-statsd' }
        when 'RedHat'
          { :statsd_package_name => 'openstack-gnocchi-statsd',
            :statsd_service_name => 'openstack-gnocchi-statsd' }
        end
      end
      it_behaves_like 'gnocchi-statsd'
    end
  end

end
