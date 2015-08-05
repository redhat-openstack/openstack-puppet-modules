require 'spec_helper'

describe Puppet::Type.type(:midonet_gateway).provider(:midonet_api_caller) do

  let(:provider) { described_class.new(resource) }

  let(:resource) { Puppet::Type.type(:midonet_gateway).new(
    {
      :ensure              => :present,
      :hostname            => 'compute.midonet',
      :midonet_api_url     => 'http://controller:8080',
      :username            => 'admin',
      :password            => 'admin',
      :interface           => 'eth0',
      :local_as            => '64512',
      :bgp_port            => { 'port_address' => '198.51.100.2', 'net_prefix' => '198.51.100.0', 'net_length' => '30' },
      :remote_peers        => [ { 'as' => '64513', 'ip' => '198.51.100.1' },
                                { 'as' => '64513', 'ip' => '203.0.113.1' } ],
      :advertise_net       => [ { 'net_prefix' => '192.0.2.0', 'net_length' => '24' } ]
    }
  )}

  describe 'BGP configuration happy path' do
    # - Create virtual ports for each remote BGP peer
    # - Configure BGP on the virtual ports or remove config if needed
    # - Advertise routes
    # - Bind virtual ports to physical network interfaces
    # - Configure stateful port group and delete it if needed
    # - Add ports to the port group and remove them if needed

    let(:routers) {
      [
        {
         "id"   => "e6a53892-03bf-4f16-8212-e4d76ad204e3",
         "name" => "MidoNet Provider Router"
        }
      ]
    }

    let(:ports) {
      [
        {
          "hostId"        => "b3f2f63e-02a6-459a-af0f-44eeac441a09",
          "interfaceName" => "eth0",
          "id"            => "20b169b1-ec0a-4639-8479-44b63e016935"
        }
      ]
    }

    let(:bgps) {
      [
        {
          "id"          => "4a5e4356-3417-4c60-9cf8-7516aedb7067",
          "localAS"     => "64512",
          "peerAS"      => "64513",
          "peerAddr"    => "198.51.100.1",
          "portId"      => "f9e61b88-0a26-4d56-8f47-eb5da37225e0"
        }
      ]
    }

    let(:port_groups) {
      [
        {
          "id"       => "711401b7-bf6f-4afd-8ab2-94b4342a0310",
          "name"     => "uplink-spg",
          "stateful" => "true"
        }
      ]
    }

    let(:hosts) {
      [
        {
          "id"   => "b3f2f63e-02a6-459a-af0f-44eeac441a09",
          "name" => "compute.midonet"
        }
      ]
    }

    let(:tenants) {
      [
        {
          "id"   => "4486908d-8e15-4f01-b3b4-86f9def0fa04",
          "name" => "4486908d-8e15-4f01-b3b4-86f9def0fa04"
        }
      ]
    }

    before :each do
      allow(provider).to receive(:call_create_uplink_port).and_return(ports)
      allow(provider).to receive(:call_get_provider_router).and_return(routers)
      allow(provider).to receive(:call_get_host_id).and_return(hosts[0]['id'])
      allow(provider).to receive(:call_get_host).and_return(hosts)
      allow(provider).to receive(:call_add_bgp_to_port)
      allow(provider).to receive(:call_get_bgp_connections).and_return(bgps)
      allow(provider).to receive(:call_advertise_route_to_bgp)
      allow(provider).to receive(:call_bind_port_to_interface)
      allow(provider).to receive(:call_get_stateful_port_group).and_return(port_groups)
      allow(provider).to receive(:call_add_ports_to_port_group)
      allow(provider).to receive(:call_delete_uplink_port).and_return(ports)
      allow(provider).to receive(:call_unbind_port_from_interface)
      allow(provider).to receive(:call_remove_ports_from_port_group)
      allow(provider).to receive(:call_get_uplink_port).and_return(ports)
      allow(provider).to receive(:call_add_route_for_uplink_port)
      allow(provider).to receive(:call_get_token).and_return('thisisafaketoken')
      allow(provider).to receive(:call_get_tenant).and_return(tenants)
    end

    it 'creates virtual ports for each remote BGP peer, advertises routes,
      binds virtual ports, configures stateful port group and adds ports to it' do
      # Expectations over the 'create' call
      expect(provider).to receive(:call_get_provider_router)
      expect(provider).to receive(:call_create_uplink_port).with(routers[0]['id'], {'portAddress'    => resource[:bgp_port]['port_address'],
                                                                                    'networkAddress' => resource[:bgp_port]['net_prefix'],
                                                                                    'networkLength'  => resource[:bgp_port]['net_length'].to_i,
                                                                                    'type' => 'Router'})
      expect(provider).to receive(:call_get_bgp_connections).with(ports[0]['id'])
      expect(provider).to receive(:call_add_bgp_to_port).with(ports[0]['id'], {'localAS'  => resource[:local_as],
                                                                               'peerAS'   => resource[:remote_peers][0]['as'],
                                                                               'peerAddr' => resource[:remote_peers][0]['ip']}).once
      expect(provider).to receive(:call_add_bgp_to_port).with(ports[0]['id'], {'localAS'  => resource[:local_as],
                                                                               'peerAS'   => resource[:remote_peers][1]['as'],
                                                                               'peerAddr' => resource[:remote_peers][1]['ip']}).once
      expect(provider).to receive(:call_add_route_for_uplink_port).with(routers[0]['id'], {'type'             => 'normal',
                                                                                           'srcNetworkAddr'   => '0.0.0.0',
                                                                                           'srcNetworkLength' => 0,
                                                                                           'dstNetworkAddr'   => resource[:bgp_port]['net_prefix'],
                                                                                           'dstNetworkLength' => resource[:bgp_port]['net_length'].to_i,
                                                                                           'weight'           => 100,
                                                                                           'nextHopPort'      => ports[0]['id']})
      expect(provider).to receive(:call_advertise_route_to_bgp).with(bgps[0]['id'], {'nwPrefix'     => resource[:advertise_net][0]['net_prefix'],
                                                                                     'prefixLength' => resource[:advertise_net][0]['net_length']}).once
      expect(provider).to receive(:call_bind_port_to_interface).with(hosts[0]['id'], {'interfaceName' => resource[:interface],
                                                                                      'portId'        => '20b169b1-ec0a-4639-8479-44b63e016935'})
      expect(provider).not_to receive(:call_create_stateful_port_group)
      expect(provider).to receive(:call_get_stateful_port_group)
      expect(provider).to receive(:call_add_ports_to_port_group).with(port_groups[0]['id'], {'portId' => '20b169b1-ec0a-4639-8479-44b63e016935'})
      provider.create
    end

    it 'deletes uplink port, port_group, and unconfigures BGP' do
      # Expectations over the 'destroy' call
      expect(provider).to receive(:call_get_provider_router)
      expect(provider).to receive(:call_get_uplink_port)
      expect(provider).to receive(:call_delete_uplink_port).with(ports[0]['id'])
      provider.destroy
    end

    it 'exists with default method returns' do
      # Expectations over the 'exists' call
      expect(provider).to receive(:call_get_provider_router).and_return(routers)
      expect(provider).to receive(:call_get_host).and_return(hosts)
      expect(provider).to receive(:call_get_uplink_port).with(routers[0]['id'], resource[:bgp_port]['port_address']).and_return(ports)
      expect(provider.exists?).to eq true
    end
  end
end
