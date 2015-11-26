require 'spec_helper'
require 'puppet'
require 'puppet/type/midonet_host_registry'
require 'facter'

describe Puppet::Type::type(:midonet_host_registry) do

  context 'on default values' do
    let(:resource) do
      Puppet::Type.type(:midonet_host_registry).new(
        :hostname        =>  Facter['hostname'].value,
        :midonet_api_url => 'http://87.23.43.2:8080/midonet-api',
        :username        => 'admin',
        :password        => 'admin')
    end

    it 'assign the default values' do
      expect(resource[:tenant_name]).to eq :'admin'
      expect(resource[:underlay_ip_address]).to eq Facter['ipaddress'].value
      expect(resource[:tunnelzone_name]).to eq :'tzone0'
      expect(resource[:tunnelzone_type]).to eq :'gre'
    end
  end

  context 'on invalid hostname' do
    it do
      expect {
        Puppet::Type.type(:midonet_host_registry).new(
          :hostname        => '_invalid_hostname.local',
          :midonet_api_url => 'http://87.23.43.2:8080/midonet-api',
          :username        => 'admin',
          :password        => 'admin')
      }.to raise_error(Puppet::ResourceError)
    end
  end

  context 'on invalid api url' do
    it do
      expect {
        Puppet::Type.type(:midonet_host_registry).new(
          :hostname        => Facter['hostname'].value,
          :midonet_api_url => '87.23.43.2:8080/midonet-api',
          :username        => 'admin',
          :password        => 'admin')
      }.to raise_error(Puppet::ResourceError)
    end
  end

  context 'on tenant_name valid value' do
    let(:resource) do
      Puppet::Type.type(:midonet_host_registry).new(
        :hostname        =>  Facter['hostname'].value,
        :midonet_api_url => 'http://87.23.43.2:8080/midonet-api',
        :username        => 'admin',
        :password        => 'admin',
        :tenant_name     => 'midokura')
    end

    it 'assign to it' do
      expect(resource[:tenant_name]).to eq 'midokura'
    end
  end

  context 'on tunnelzone valid name' do
    let(:resource) do
      Puppet::Type.type(:midonet_host_registry).new(
        :hostname        =>  Facter['hostname'].value,
        :midonet_api_url => 'http://87.23.43.2:8080/midonet-api',
        :username        => 'admin',
        :password        => 'admin',
        :tunnelzone_name => 'tzoneee')
    end

    it 'assign to it' do
      expect(resource[:tunnelzone_name]).to eq 'tzoneee'
    end
  end

  context 'on tunnelzone valid type gre' do
    let(:resource) do
      Puppet::Type.type(:midonet_host_registry).new(
        :hostname        =>  Facter['hostname'].value,
        :midonet_api_url => 'http://87.23.43.2:8080/midonet-api',
        :username        => 'admin',
        :password        => 'admin',
        :tunnelzone_type => 'gre')
    end

    it 'assign to it' do
      expect(resource[:tunnelzone_type]).to eq :'gre'
    end
  end

  context 'on tunnelzone valid type vxlan' do
    let(:resource) do
      Puppet::Type.type(:midonet_host_registry).new(
        :hostname        =>  Facter['hostname'].value,
        :midonet_api_url => 'http://87.23.43.2:8080/midonet-api',
        :username        => 'admin',
        :password        => 'admin',
        :tunnelzone_type => 'vxlan')
    end

    it 'assign to it' do
      expect(resource[:tunnelzone_type]).to eq :'vxlan'
    end
  end

  context 'on tunnelzone valid type foo' do
    it do
      expect {
        Puppet::Type.type(:midonet_host_registry).new(
          :hostname        =>  Facter['hostname'].value,
          :midonet_api_url => 'http://87.23.43.2:8080/midonet-api',
          :username        => 'admin',
          :password        => 'admin',
          :tunnelzone_type => 'foo')
      }.to raise_error(Puppet::ResourceError)
    end
  end

  context 'on underlay_ip_address valid IP' do
    let(:resource) do
      Puppet::Type.type(:midonet_host_registry).new(
        :hostname            =>  Facter['hostname'].value,
        :midonet_api_url     => 'http://87.23.43.2:8080/midonet-api',
        :username            => 'admin',
        :password            => 'admin',
        :underlay_ip_address => '76.3.176.129')
    end

    it 'assign it properly' do
      expect(resource[:underlay_ip_address]).to eq '76.3.176.129'
    end
  end

  context 'on underlay_ip_address invalid IP' do

    it do
      expect {
        Puppet::Type.type(:midonet_host_registry).new(
          :hostname            =>  Facter['hostname'].value,
          :midonet_api_url     => 'http://87.23.43.2:8080/midonet-api',
          :username            => 'admin',
          :password            => 'admin',
          :underlay_ip_address => '76.3.280.129')
      }.to raise_error(Puppet::ResourceError)
    end

  end
end
