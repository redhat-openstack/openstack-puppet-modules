require 'spec_helper'

describe Puppet::Type.type(:pacemaker_pcsd_auth).provider(:pcs) do
  let(:resource) do
    Puppet::Type.type(:pacemaker_pcsd_auth).new(
        name: 'auth',
        nodes: %w(node1 node2 node3),
        username: 'my_user',
        password: 'my_password',
        provider: :pcs,
    )
  end

  let(:provider) do
    resource.provider
  end

  subject { provider }

  let(:whole_success_data) do
    {
        'node1' => 'already_authorized',
        'node2' => 'ok',
        'node3' => 'ok',
    }
  end

  let(:local_success_data) do
    {
        'node1' => 'ok',
        'node2' => 'noresponse',
        'node3' => 'noresponse',
    }
  end

  let(:bad_password_data) do
    {
        'node1' => 'bad_password',
        'node2' => 'bad_password',
        'node3' => 'bad_password',
    }
  end

  before(:each) do
    puppet_debug_override
    subject.pacemaker_options[:retry_step] = 0
    subject.stubs(:pcs_auth_command)
    subject.stubs(:node_name).returns('node1')
  end

  context 'validate' do
    it 'will conversi a single node to array' do
      resource[:nodes] = 'node1'
      expect(resource[:nodes]).to eq 'node1'
      subject.validate_input
      expect(resource[:nodes]).to eq ['node1']
    end

    it 'will fail if username and password are not provided' do
      resource[:username] = false
      expect do
        subject.validate_input
      end.to raise_error Puppet::Error, /Both username and password/
    end

    it 'will fail if nodes are not provided' do
      resource[:nodes] = []
      expect do
        subject.validate_input
      end.to raise_error Puppet::Error, /At least one node/
    end
  end

  context 'pcs cluster auth command' do
    it 'runs the command and parses the results' do
      subject.expects(:pcs_auth_command).returns('test')
      subject.expects(:pcs_auth_parse).with('test').returns(whole_success_data)
      subject.cluster_auth
    end

    it 'will fail if the data was not received' do
      expect do
        subject.expects(:pcs_auth_command).returns(nil)
        subject.cluster_auth
      end.to raise_error Puppet::Error, /Could not parse the result/
    end

    it 'will fail if the data was not parsed' do
      expect do
        subject.expects(:pcs_auth_command).returns('test')
        subject.expects(:pcs_auth_parse).with('test').returns(nil)
        subject.cluster_auth
      end.to raise_error Puppet::Error, /Could not parse the result/
    end
  end

  context 'local node mode' do
    before(:each) do
      resource[:whole] = false
    end

    it 'will return success if all nodes are authenticated' do
      subject.expects(:cluster_auth).returns(whole_success_data)
      expect(subject.success).to eq true
    end

    it 'will check if the whole cluster is successful first' do
      subject.expects(:cluster_auth).returns(whole_success_data)
      subject.expects(:whole_auth_success?).with(whole_success_data).returns(true)
      subject.expects(:local_auth_success?).never
      expect(subject.success).to eq true
    end

    it 'will return success if at least local node is authenticated' do
      subject.expects(:cluster_auth).returns(local_success_data)
      expect(subject.success).to eq true
    end

    it 'will not return success if all nodes have failed' do
      subject.expects(:cluster_auth).returns(bad_password_data)
      expect(subject.success).to eq false
    end

  end

  context 'whole cluster mode' do
    it 'will return success if all nodes are authenticated' do
      subject.expects(:cluster_auth).returns(whole_success_data)
      expect(subject.success).to eq true
    end

    it 'will not return success if at least local node is authenticated' do
      subject.expects(:cluster_auth).returns(local_success_data)
      expect(subject.success).to eq false
    end

    it 'will not return success if all nodes have failed' do
      subject.expects(:cluster_auth).returns(bad_password_data)
      expect(subject.success).to eq false
    end
  end

  context 'enforce' do
    it 'will not do anything if success is not set to true' do
      subject.expects(:retry_block).never
      subject.success = false
    end

    it 'will retry the success check until is passes' do
      subject.expects(:success).returns(false, false, true).times(3)
      subject.success = true
    end
  end
end
