require 'spec_helper'
require 'puppet'
require 'puppet/type/midonet_gateway'
require 'facter'

describe Puppet::Type::type(:midonet_gateway) do

    context 'on default values' do
        let(:resource) do
            Puppet::Type::type(:midonet_gateway).new(
                :hostname        => Facter['hostname'].value,
                :midonet_api_url => 'http://controller:8080/midonet-api',
                :username        => 'admin',
                :password        => 'admin',
                :interface       => 'eth0',
                :local_as        => '64512',
                :bgp_port        => { 'port_address' => '198.51.100.2', 'net_prefix' => '198.51.100.0', 'net_length' => '30'},
                :remote_peers    => [ { 'as' => '64513', 'ip' => '198.51.100.1' },
                                      { 'as' => '64513', 'ip' => '203.0.113.1' } ],
                :advertise_net   => [ { 'net_prefix' => '192.0.2.0', 'net_length' => '24' } ])

        end

        it 'assign the default values' do
            expect(resource[:username]).to eq 'admin'
            expect(resource[:password]).to eq 'admin'
            expect(resource[:tenant_name]).to eq 'admin'
            expect(resource[:interface]).to eq 'eth0'
            expect(resource[:router]).to eq 'MidoNet Provider Router'
        end
    end

    context 'on invalid hostname' do
        it do
            expect {
                Puppet::Type.type(:midonet_gateway).new(
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
                Puppet::Type.type(:midonet_gateway).new(
                    :hostname        => Facter['hostname'].value,
                    :midonet_api_url => '87.23.43.2:8080/midonet-api',
                    :username        => 'admin',
                    :password        => 'admin')
                }.to raise_error(Puppet::ResourceError)
        end
    end

    context 'on tenant_name valid value' do
        let(:resource) do
            Puppet::Type.type(:midonet_gateway).new(
                :hostname        => Facter['hostname'].value,
                :midonet_api_url => 'http://87.23.43.2:8080/midonet-api',
                :username        => 'admin',
                :password        => 'admin',
                :tenant_name     => 'midokura')
        end

        it 'assign to it' do
            expect(resource[:tenant_name]).to eq 'midokura'
        end
    end

    context 'on valid interface name' do
        let(:resource) do
            Puppet::Type.type(:midonet_gateway).new(
                :hostname        => Facter['hostname'].value,
                :midonet_api_url => 'http://87.23.43.2:8080/midonet-api',
                :username        => 'admin',
                :password        => 'admin',
                :interface       => 'eth0')
        end

        it 'assign to it' do
            expect(resource[:interface]).to eq 'eth0'
        end
    end

    context 'on valid local AS name' do
        let(:resource) do
            Puppet::Type.type(:midonet_gateway).new(
                :hostname        => Facter['hostname'].value,
                :midonet_api_url => 'http://87.23.43.2:8080/midonet-api',
                :username        => 'admin',
                :password        => 'admin',
                :local_as        => '64512')
        end

        it 'assign to it' do
            expect(resource[:local_as]).to eq '64512'
        end
    end

    context 'on invalid local AS name' do
        it do
            expect {
                Puppet::Type.type(:midonet_gateway).new(
                    :hostname        => Facter['hostname'].value,
                    :midonet_api_url => 'http://87.23.43.2:8080/midonet-api',
                    :username        => 'admin',
                    :password        => 'admin',
                    :local_as        => 'fake')
                }.to raise_error(Puppet::ResourceError)
        end
    end

    context 'on invalid BGP port' do
        it do
            expect {
                Puppet::Type.type(:midonet_gateway).new(
                    :hostname        => Facter['hostname'].value,
                    :midonet_api_url => 'http://87.23.43.2:8080/midonet-api',
                    :username        => 'admin',
                    :password        => 'admin',
                    :bgp_port        => { 'port_address' => '_198.51.100.2',
                                          'net_prefix'  => '198.51.100.0',
                                          'net_length'   => '30' })
                }.to raise_error(Puppet::ResourceError)
        end
    end

    context 'on invalid remote BGP peers AS name and IP' do
        it do
            expect {
                Puppet::Type.type(:midonet_gateway).new(
                    :hostname        => Facter['hostname'].value,
                    :midonet_api_url => 'http://87.23.43.2:8080/midonet-api',
                    :username        => 'admin',
                    :password        => 'admin',
                    :remote_peers    => [ { 'as' => 'fake',
                                            'ip' => '_198.51.100.1' } ])
                }.to raise_error(Puppet::ResourceError)
        end
    end

    context 'on valid router name' do
        let(:resource) do
            Puppet::Type.type(:midonet_gateway).new(
                :hostname        => Facter['hostname'].value,
                :midonet_api_url => 'http://87.23.43.2:8080/midonet-api',
                :username        => 'admin',
                :password        => 'admin',
                :router          => 'MidoNet Provider Router')
        end

        it 'assign to it' do
            expect(resource[:router]).to eq 'MidoNet Provider Router'
        end
    end

    context 'on invalid advertise network' do
        it do
            expect {
                Puppet::Type.type(:midonet_gateway).new(
                    :hostname        => Facter['hostname'].value,
                    :midonet_api_url => 'http://87.23.43.2:8080/midonet-api',
                    :username        => 'admin',
                    :password        => 'admin',
                    :advertise_net   => [ { 'net_prefix' => '_192.0.2.0',
                                            'net_length' => '24' } ] )
                }.to raise_error(Puppet::ResourceError)
        end
    end

end

