require 'spec_helper'

describe 'manila::network::nova_single_network' do
  let("title") {'novasinglenet'}

  let :params do
    {
      :nova_single_network_plugin_net_id  => 'abcdef',
    }
  end

  context 'with provided parameters' do
    it 'configures nova network plugin' do

      is_expected.to contain_manila_config("novasinglenet/network_api_class").with_value(
        'manila.network.nova_network_plugin.NovaSingleNetworkPlugin')

      params.each_pair do |config,value|
        is_expected.to contain_manila_config("novasinglenet/#{config}").with_value( value )
      end
    end
  end
end
