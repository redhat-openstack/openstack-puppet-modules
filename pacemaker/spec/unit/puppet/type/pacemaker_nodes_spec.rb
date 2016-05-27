require 'spec_helper'

describe Puppet::Type.type(:pacemaker_nodes) do
  subject do
    Puppet::Type.type(:pacemaker_nodes).new(name: 'pacemaker', nodes: nodes_data)
  end

  let(:nodes_data) do
    {
        'node-1' => {'ip' => '192.168.0.1', 'id' => '1'},
        'node-2' => {'ip' => '192.168.0.2', 'id' => '2'},
        'node-3' => {'ip' => '192.168.0.3', 'id' => '3'},
        'node-4' => {'ip' => '192.168.0.4', 'id' => '4'},
    }
  end

  let(:corosync_nodes_data) do
    {
        '1' => '192.168.0.1',
        '2' => '192.168.0.2',
        '3' => '192.168.0.3',
        '4' => '192.168.0.4',
    }
  end

  let(:pacemaker_nodes_data) do
    {
        'node-1' => '1',
        'node-2' => '2',
        'node-3' => '3',
        'node-4' => '4',
    }
  end

  it "should have a 'name' parameter" do
    expect(subject[:name]).to eq 'pacemaker'
  end

  it "should have a 'nodes' parameter" do
    expect(subject[:nodes]).to eq nodes_data
  end

  it 'should fail if nodes data is not provided or incorrect' do
    expect {
      subject[:nodes] = nil
    }.to raise_error(/Got nil value for nodes/)
    expect {
      subject[:nodes] = 'node-1'
    }.to raise_error(/Nodes should be a non-empty hash/)
  end

end
