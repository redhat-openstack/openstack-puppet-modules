require 'spec_helper'

describe 'mistral::executor' do

  let :params do
    { :enabled             => true,
      :manage_service      => true,
      :host                => true,
      :topic               => true,
      :version             => true,
      :evaluation_interval => 1234,
      :older_than          => 60}
  end

  shared_examples_for 'mistral-executor' do

    context 'config params' do

      it { is_expected.to contain_class('mistral::params') }

      it { is_expected.to contain_mistral_config('executor/host').with_value( params[:host] ) }
      it { is_expected.to contain_mistral_config('executor/topic').with_value( params[:topic] ) }
      it { is_expected.to contain_mistral_config('executor/version').with_value( params[:version] ) }
      it { is_expected.to contain_mistral_config('execution_expiration_policy/evaluation_interval').with_value( params[:evaluation_interval] ) }
      it { is_expected.to contain_mistral_config('execution_expiration_policy/older_than').with_value( params[:older_than] ) }

    end

    [{:enabled => true}, {:enabled => false}].each do |param_hash|
      context "when service should be #{param_hash[:enabled] ? 'enabled' : 'disabled'}" do
        before do
          params.merge!(param_hash)
        end

        it 'configures mistral-executor service' do

          is_expected.to contain_service('mistral-executor').with(
            :ensure     => (params[:manage_service] && params[:enabled]) ? 'running' : 'stopped',
            :name       => platform_params[:executor_service_name],
            :enable     => params[:enabled],
            :hasstatus  => true,
            :hasrestart => true,
            :tag        => 'mistral-service',
          )
          is_expected.to contain_service('mistral-executor').that_subscribes_to(nil)
        end
      end
    end

    context 'with disabled service managing' do
      before do
        params.merge!({
          :manage_service => false,
          :enabled        => false })
      end

      it 'configures mistral-executor service' do

        is_expected.to contain_service('mistral-executor').with(
          :ensure     => nil,
          :name       => platform_params[:executor_service_name],
          :enable     => false,
          :hasstatus  => true,
          :hasrestart => true,
          :tag        => 'mistral-service',
        )
        is_expected.to contain_service('mistral-executor').that_subscribes_to(nil)
      end
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    let :platform_params do
      { :executor_service_name => 'mistral-executor' }
    end

    it_configures 'mistral-executor'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    let :platform_params do
      { :executor_service_name => 'openstack-mistral-executor' }
    end

    it_configures 'mistral-executor'
  end

end
