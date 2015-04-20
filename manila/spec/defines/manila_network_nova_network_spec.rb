require 'spec_helper'

describe 'manila::network::nova_network' do
  let("title") {'novanet'}

  context 'with provided parameters' do
    it 'configures nova network plugin' do

      is_expected.to contain_manila_config("novanet/network_api_class").with_value(
        'manila.network.nova_network_plugin.NovaNetworkPlugin')

    end
  end
end
