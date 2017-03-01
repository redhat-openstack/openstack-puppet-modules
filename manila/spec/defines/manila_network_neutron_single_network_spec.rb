require 'spec_helper'

describe 'manila::network::neutron_single_network' do
  let("title") {'neutronsingle'}

  let :params do
    {
      :neutron_net_id     => 'abcdef',
      :neutron_subnet_id  => 'ghijkl',
    }
  end

  context 'with provided parameters' do
    it 'configures neutron single network plugin' do

      is_expected.to contain_manila_config("neutronsingle/network_api_class").with_value(
        'manila.network.neutron.neutron_network_plugin.NeutronSingleNetworkPlugin')

      params.each_pair do |config,value|
        is_expected.to contain_manila_config("neutronsingle/#{config}").with_value( value )
      end
    end
  end
end
