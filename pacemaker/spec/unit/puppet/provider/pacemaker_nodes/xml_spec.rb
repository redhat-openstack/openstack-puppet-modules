require 'spec_helper'

describe Puppet::Type.type(:pacemaker_nodes).provider(:xml) do
  let(:resource) do
    Puppet::Type.type(:pacemaker_nodes).new(
        name: 'pacemaker',
        nodes: nodes_data,
        provider: :xml,
    )
  end

  let(:provider) do
    resource.provider
  end

  before(:each) do
    puppet_debug_override
  end

  # output of corosync_cmapctl -b nodelist
  let(:cmap_nodelist) do
    <<-eos
nodelist.node.0.nodeid (u32) = 1
nodelist.node.0.ring0_addr (str) = 192.168.0.1
nodelist.node.0.ring1_addr (str) = 172.16.0.1

nodelist.node.1.nodeid (u32) = 2
nodelist.node.1.ring0_addr (str) = 192.168.0.2
nodelist.node.1.ring1_addr (str) = 172.16.0.2

nodelist.node.2.nodeid (u32) = 3
nodelist.node.2.ring0_addr (str) = 192.168.0.3
nodelist.node.2.ring1_addr (str) = 172.16.0.3
    eos
  end

  # comes from 'nodes' library method
  let(:pacemaker_nodes) do
    {
        'node-1' => {'id' => '1', 'uname' => 'node-1'},
        'node-2' => {'id' => '2', 'uname' => 'node-2'},
        'node-3' => {'id' => '3', 'uname' => 'node-3'},
    }
  end

  # retrieved corosync nodes state
  let(:corosync_nodes_structure) do
    {
        '1' => {'id' => '1', 'number' => '0', 'ring0' => '192.168.0.1', 'ring1' => '172.16.0.1'},
        '2' => {'id' => '2', 'number' => '1', 'ring0' => '192.168.0.2', 'ring1' => '172.16.0.2'},
        '3' => {'id' => '3', 'number' => '2', 'ring0' => '192.168.0.3', 'ring1' => '172.16.0.3'},
    }
  end

  # generated existing pacemaker nodes structure
  let(:pacemaker_nodes_structure) do
    {
        '1' => 'node-1',
        '2' => 'node-2',
        '3' => 'node-3',
    }
  end

  # 'nodes' property input data
  let(:nodes_data) do
    {
        '1' => {
            'name' => 'node1',
            'id' => '1',
            'ring0' => '192.168.0.1',
            'ring1' => '172.16.0.1',
        },
        '2' => {
            'name' => 'node2',
            'id' => '2',
            'ring0' => '192.168.0.2',
            'ring1' => '172.16.0.2',
        },
        '3' => {
            'name' => 'node3',
            'id' => '3',
            'ring0' => '192.168.0.3',
            'ring1' => '172.16.0.3',
        }
    }
  end

  before(:each) do
    provider.stubs(:cmapctl_nodelist).returns cmap_nodelist
    provider.stubs(:nodes).returns pacemaker_nodes
  end

  context 'data structures' do
    it 'corosync_nodes_structure' do
      expect(provider.corosync_nodes_structure).to eq(corosync_nodes_structure)
    end

    it 'pacemaker_nodes_structure' do
      expect(provider.pacemaker_nodes_structure).to eq(pacemaker_nodes_structure)
    end
  end

end
