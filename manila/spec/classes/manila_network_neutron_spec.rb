require 'spec_helper'

describe 'manila::network::neutron' do

  let :params do
    {
      :neutron_admin_username       => 'neutron',
      :neutron_admin_password       => 'password',
      :neutron_admin_tenant_name    => 'service',
      :neutron_region_name          => 'nova',
      :neutron_ca_certificates_file => '/etc/neutron/ca-certificates',
    }
  end

  let :default_params do
    {
      :neutron_url                  => 'http://127.0.0.1:9696',
      :neutron_url_timeout          => 30,
      :neutron_admin_tenant_name    => 'service',
      :neutron_admin_auth_url       => 'http://localhost:5000/v2.0',
      :neutron_api_insecure         => false,
      :neutron_auth_strategy        => 'keystone',
    }
  end


  shared_examples_for 'neutron network plugin' do
    let :params_hash do
      default_params.merge(params)
    end

    it 'configures neutron network plugin' do

      is_expected.to contain_manila_config("DEFAULT/network_api_class").with_value(
        'manila.network.neutron.neutron_network_plugin.NeutronNetworkPlugin')

      params_hash.each_pair do |config,value|
        is_expected.to contain_manila_config("DEFAULT/#{config}").with_value( value )
      end
    end
  end


  context 'with default parameters' do
    before do
      params = {}
    end

    it_configures 'neutron network plugin'
  end

  context 'with provided parameters' do
    it_configures 'neutron network plugin'
  end
end
