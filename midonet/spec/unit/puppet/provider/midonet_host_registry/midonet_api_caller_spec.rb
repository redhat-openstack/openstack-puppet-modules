require 'spec_helper'

describe Puppet::Type.type(:midonet_host_registry).provider(:midonet_api_caller) do

  let(:provider) { described_class.new(resource) }

  let(:resource) { Puppet::Type.type(:midonet_host_registry).new(
    {
      :ensure              => :present,
      :hostname            => 'compute.midonet',
      :midonet_api_url     => 'http://controller:8080',
      :username            => 'username',
      :password            => 'password',
      :tunnelzone_name     => 'tzone1',
      :underlay_ip_address => '172.10.0.10'
    }
  )}

  describe 'host registry happy path' do
    # - Single tunnelzone zones
    # - Host registered
    # - Allow to be created, and deleted
    # - Tunnel zone should be deleted after the host deletion

    let(:tzones) {
      [
        {
          "name" => "tzone1",
          "id"   => "bd69f96a-005b-4d58-9f6c-b8dd9fbb6339",
          "type" => "gre"
        }
      ]
    }

    let(:hosts) {
      [
        {
          "id"   => "04f7361c-4cb8-4cda-a50f-1744fd8b7851",
          "name" => "compute.midonet"
        }
      ]
    }

    before :each do
      allow(provider).to receive(:call_get_tunnelzone).and_return(tzones)
      allow(provider).to receive(:call_get_host).and_return(hosts)
      allow(provider).to receive(:call_create_tunnelzone_host)
      allow(provider).to receive(:call_get_tunnelzone_host).and_return(hosts)
      allow(provider).to receive(:call_delete_tunnelzone_host)
      allow(provider).to receive(:call_get_tunnelzone_hosts).and_return([])
      allow(provider).to receive(:call_delete_tunnelzone)
      allow(provider).to receive(:call_get_token).and_return('thisisafaketoken')
    end

    it 'registers the host successfully' do
      # Expectations over 'create' call
      expect(provider).to receive(:call_create_tunnelzone_host).with(tzones[0]['id'], {'hostId' => '04f7361c-4cb8-4cda-a50f-1744fd8b7851', 'ipAddress' => '172.10.0.10'})
      expect(provider).to receive(:call_get_tunnelzone)
      expect(provider).not_to receive(:call_create_tunnelzone)
      expect(provider).to receive(:call_get_host)
      provider.create
    end

    it 'unregisters the host successfully' do
      # Expectations over the 'destroy' call
      expect(provider).to receive(:call_get_tunnelzone)
      expect(provider).to receive(:call_get_host)
      expect(provider).to receive(:call_get_tunnelzone_hosts).with(tzones[0]['id'])
      expect(provider).to receive(:call_delete_tunnelzone)
      provider.destroy
    end

  end

  describe 'when no tunnelzones' do
    let(:hosts) {
      [
        {
          "id"   => "04f7361c-4cb8-4cda-a50f-1744fd8b7851",
          "name" => "compute.midonet"
        }
      ]
    }

    let(:tzones) {
      [
        {
          "name" => "tzone1",
          "id"   => "bd69f96a-005b-4d58-9f6c-b8dd9fbb6339",
          "type" => "gre"
        }
      ]
    }

    it 'creates the tunnelzone and the host' do
      allow(provider).to receive(:call_get_tunnelzone).and_return([])
      allow(provider).to receive(:call_create_tunnelzone).and_return(tzones)
      allow(provider).to receive(:call_get_host).and_return(hosts)
      allow(provider).to receive(:call_create_tunnelzone_host)
      allow(provider).to receive(:call_get_token).and_return('thisisafaketoken')

      expect(provider).to receive(:call_create_tunnelzone).once
      expect(provider.exists?).to eq false

      provider.create
    end
  end

  describe 'unregister not the last host in tunnelzone' do
    let(:tzones) {
      [
        {
          "name" => "tzone1",
          "id"   => "bd69f96a-005b-4d58-9f6c-b8dd9fbb6339",
          "type" => "gre"
        }
      ]
    }

    let(:host_to_unregister) {
      [
        {
          "id"   => "04f7361c-4cb8-4cda-a50f-1744fd8b7851",
          "name" => "compute.midonet"
        }
      ]
    }

    let(:host_left_in_tunnelzone) {
      [
        {
          "id"   => "04f7361c-4cb8-4cda-a50f-1744fd8b7852",
          "name" => "compute2.midonet"
        }
      ]
    }

    it 'should not call the tunnelzone deletion' do
      # Preparing the rest responses
      allow(provider).to receive(:call_get_tunnelzone).and_return(tzones)
      allow(provider).to receive(:call_get_host).and_return(host_to_unregister)
      allow(provider).to receive(:call_delete_tunnelzone_host)
      allow(provider).to receive(:call_get_tunnelzone_host).and_return(host_to_unregister)
      allow(provider).to receive(:call_get_tunnelzone_hosts).and_return(host_left_in_tunnelzone)
      allow(provider).to receive(:call_get_token).and_return('thisisafaketoken')

      # Set the behaviour expectations
      expect(provider).to receive(:call_delete_tunnelzone_host).with(tzones[0]['id'], host_to_unregister[0]['id'])
      expect(provider).not_to receive(:call_delete_tunnelzone)

      provider.destroy
    end
  end

  describe 'try to register a host without midonet-agent' do
    let(:tzones) {
      [
        {
          "name" => "tzone1",
          "id"   => "bd69f96a-005b-4d58-9f6c-b8dd9fbb6339",
          "type" => "gre"
        }
      ]
    }

    it 'should raise an exception' do
      # Preparing the rest responses
      allow(provider).to receive(:call_get_tunnelzone).and_return(tzones)
      allow(provider).to receive(:call_get_host).and_return([])
      allow(provider).to receive(:call_get_token).and_return('thisisafaketoken')
      expect {
        provider.create
      }.to raise_error(RuntimeError)
    end
  end

  describe 'try to register a host with wrong tunnelzone type' do
    let(:tzones) {
      [
        {
          "name" => "tzone1",
          "id"   => "bd69f96a-005b-4d58-9f6c-b8dd9fbb6339",
          "type" => "vxlan"    # Resource is 'gre' and current one is 'vxlan'
        }
      ]
    }

    it 'should raise an exception' do
      allow(provider).to receive(:call_get_tunnelzone).and_return(tzones)
      allow(provider).to receive(:call_get_token).and_return('thisisafaketoken')
      expect {
        provider.create
      }.to raise_error(RuntimeError)
    end
  end

  describe 'try to unregister a host that belongs to a tunnelzone that does not exist' do
    it 'should not fail' do
      allow(provider).to receive(:call_get_tunnelzone).and_return([])
      allow(provider).to receive(:call_get_token).and_return('thisisafaketoken')
      expect(provider).not_to receive(:call_delete_tunnelzone_host)
      provider.destroy
    end
  end

  describe 'try to unregister a host that does not exist' do
    let(:tzones) {
      [
        {
          "name" => "tzone1",
          "id"   => "bd69f96a-005b-4d58-9f6c-b8dd9fbb6339",
          "type" => "gre"
        }
      ]
    }

    it 'should not fail' do
      allow(provider).to receive(:call_get_tunnelzone).and_return(tzones)
      allow(provider).to receive(:call_get_host).and_return([])
      allow(provider).to receive(:call_get_token).and_return('thisisafaketoken')

      expect(provider).not_to receive(:call_delete_tunnelzone_host)

      provider.destroy
    end
  end

  describe 'try to unregister a host that does not belong to a tunnelzone' do
    let(:tzones) {
      [
        {
          "name" => "tzone1",
          "id"   => "bd69f96a-005b-4d58-9f6c-b8dd9fbb6339",
          "type" => "gre"
        }
      ]
    }

    let(:hosts) {
      [
        {
          "id"   => "04f7361c-4cb8-4cda-a50f-1744fd8b7851",
          "name" => "compute.midonet"
        }
      ]
    }

    it 'should not fail' do
      allow(provider).to receive(:call_get_tunnelzone).and_return(tzones)
      allow(provider).to receive(:call_get_host).and_return(hosts)
      allow(provider).to receive(:call_get_tunnelzone_host).and_return([])
      allow(provider).to receive(:call_get_token).and_return('thisisafaketoken')

      expect(provider).to receive(:call_get_tunnelzone).once
      expect(provider).to receive(:call_get_host).once
      expect(provider).to receive(:call_get_tunnelzone_host).once.with(tzones[0]['id'], hosts[0]['id'])

      provider.destroy
    end
  end

end
