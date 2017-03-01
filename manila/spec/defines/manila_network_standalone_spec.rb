require 'spec_helper'

describe 'manila::network::standalone' do
  let("title") {'standalone'}

  let :params do
    {
      :standalone_network_plugin_gateway            => '192.168.1.1',
      :standalone_network_plugin_mask               => '255.255.255.0',
      :standalone_network_plugin_segmentation_id    => '1001',
      :standalone_network_plugin_allowed_ip_ranges  => '10.0.0.10-10.0.0.20',
    }
  end

  let :default_params do
    {
      :standalone_network_plugin_ip_version         => '4',
    }
  end


  shared_examples_for 'standalone network plugin' do
    let :params_hash do
      default_params.merge(params)
    end

    it 'configures standalone network plugin' do

      is_expected.to contain_manila_config("standalone/network_api_class").with_value(
        'manila.network.standalone_network_plugin.StandaloneNetworkPlugin')

      params_hash.each_pair do |config,value|
        is_expected.to contain_manila_config("standalone/#{config}").with_value( value )
      end
    end
  end


  context 'with default parameters' do
    before do
      params = {}
    end

    it_configures 'standalone network plugin'
  end

  context 'with provided parameters' do
    it_configures 'standalone network plugin'
  end
end
