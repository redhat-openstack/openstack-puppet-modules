require 'spec_helper'

require_relative '../../../../lib/puppet/provider/pacemaker_pcs'

describe Puppet::Provider::PacemakerPCS do
  before(:each) do
    puppet_debug_override
    subject.pacemaker_options[:retry_step] = 0
  end

  context 'Common' do
    it 'can call a safe pcs command' do
      subject.expects(:pcs).with('status').returns('test')
      expect(subject.pcs_safe 'status').to eq 'test'
    end

    it 'will not call the pcs command in debug mode' do
      subject.expects(:debug_mode_enabled?).returns(true)
      subject.expects(:pcs).never
      subject.pcs_safe 'status'
    end

    it 'can parse a list of keys and values' do
      list = <<-eof
key1: value
key2: 1
key3: true
key4: false
garbage
:garbage
garbage:

      eof

      data = {
          'key1' => 'value',
          'key2' => '1',
          'key3' => true,
          'key4' => false,
      }
      expect(subject.pcs_list_to_hash list).to eq data
    end
  end

  context 'Resource Default' do
    let(:data) do
      {
          'resource-stickiness' => '200',
      }
    end

    before(:each) do
      subject.stubs(:pcs_resource_defaults).returns(data)
    end

    it 'can check that resource default is set' do
      expect(subject.pcs_resource_default_defined? 'resource-stickiness').to eq true
      expect(subject.pcs_resource_default_defined? 'target-state').to eq false
    end

    it 'can get a resource default value' do
      expect(subject.pcs_resource_default_value 'resource-stickiness').to eq '200'
      expect(subject.pcs_resource_default_value 'target-state').to eq nil
    end

    it 'can set a resource defaults value' do
      cmd = %w(resource defaults target-state=Started)
      subject.expects(:pcs).with(cmd).returns(true)
      subject.pcs_resource_default_set 'target-state', 'Started'
    end

    it 'can remove a resource defaults' do
      cmd = %w(resource defaults target-state=)
      subject.expects(:pcs).with(cmd).returns(true)
      subject.pcs_resource_default_delete 'target-state'
    end
  end

  context 'Operation Default' do
    let(:data) do
      {
          'timeout' => '60',
      }
    end

    before(:each) do
      subject.stubs(:pcs_operation_defaults).returns(data)
    end

    it 'can check that operation default is set' do
      expect(subject.pcs_operation_default_defined? 'timeout').to eq true
      expect(subject.pcs_operation_default_defined? 'interval').to eq false
    end

    it 'can get a operation default value' do
      expect(subject.pcs_operation_default_value 'timeout').to eq '60'
      expect(subject.pcs_operation_default_value 'interval').to eq nil
    end

    it 'can set a operation defaults value' do
      cmd = %w(resource op defaults interval=20)
      subject.expects(:pcs).with(cmd).returns(true)
      subject.pcs_operation_default_set 'interval', '20'
    end

    it 'can remove a operation defaults' do
      cmd = %w(resource op defaults interval=)
      subject.expects(:pcs).with(cmd).returns(true)
      subject.pcs_operation_default_delete 'interval'
    end
  end

  context 'Properties' do
    let(:data) do
      {
          'symmetric-cluster' => true,
      }
    end

    before(:each) do
      subject.stubs(:pcs_cluster_properties).returns(data)
    end

    it 'can check that property is set' do
      expect(subject.pcs_cluster_property_defined? 'symmetric-cluster').to eq true
      expect(subject.pcs_cluster_property_defined? 'no-quorum-policy').to eq false
    end

    it 'can get a property value' do
      expect(subject.pcs_cluster_property_value 'symmetric-cluster').to eq true
      expect(subject.pcs_cluster_property_value 'no-quorum-policy').to eq nil
    end

    it 'can set a property value' do
      cmd = %w(property set no-quorum-policy=ignore)
      subject.expects(:pcs).with(cmd).returns(true)
      subject.pcs_cluster_property_set 'no-quorum-policy', 'ignore'
    end

    it 'can remove a property' do
      cmd = %w(property unset no-quorum-policy)
      subject.expects(:pcs).with(cmd).returns(true)
      subject.pcs_cluster_property_delete 'no-quorum-policy'
    end
  end

  context 'Pcsd Auth' do
    let(:sample_output) do
      <<-'eof'
Running: /usr/bin/ruby -I/usr/lib/pcsd/ /usr/lib/pcsd/pcsd-cli.rb auth
--Debug Input Start--
{"username": "hacluster", "local": false, "nodes": ["node1", "node2"], "password": "hacluster", "force": false}
--Debug Input End--

Return Value: 0
--Debug Output Start--
{
  "status": "ok",
  "data": {
    "auth_responses": {
      "node1": {
        "status": "already_authorized"
      },
      "node2": {
        "status": "noresponse"
      }
    },
    "sync_successful": true,
    "sync_nodes_err": [

    ],
    "sync_responses": {
    }
  },
  "log": [
    "I, [2016-04-12T23:27:47.640069 #31527]  INFO -- : PCSD Debugging enabled\n",
    "D, [2016-04-12T23:27:47.640612 #31527] DEBUG -- : Did not detect RHEL 6\n",
    "I, [2016-04-12T23:27:47.640705 #31527]  INFO -- : Running: /usr/sbin/corosync-cmapctl totem.cluster_name\n",
    "I, [2016-04-12T23:27:47.640779 #31527]  INFO -- : CIB USER: hacluster, groups: \n",
    "D, [2016-04-12T23:27:47.644752 #31527] DEBUG -- : []\n",
    "D, [2016-04-12T23:27:47.644958 #31527] DEBUG -- : Duration: 0.003927199s\n",
    "I, [2016-04-12T23:27:47.645148 #31527]  INFO -- : Return Value: 1\n",
    "W, [2016-04-12T23:27:47.645429 #31527]  WARN -- : Cannot read config 'corosync.conf' from '/etc/corosync/corosync.conf': No such file or directory - /etc/corosync/corosync.conf\n",
    "I, [2016-04-12T23:27:47.646517 #31527]  INFO -- : SRWT Node: node2 Request: check_auth\n",
    "I, [2016-04-12T23:27:47.648696 #31527]  INFO -- : SRWT Node: node1 Request: check_auth\n",
    "I, [2016-04-12T23:27:47.650378 #31527]  INFO -- : No response from: node2 request: /check_auth, exception: Connection refused - connect(2)\n"
  ]
}

--Debug Output End--

node1: Already authorized
      eof
    end

    let(:debug_block) do
      <<-'eof'
{
  "status": "ok",
  "data": {
    "auth_responses": {
      "node1": {
        "status": "already_authorized"
      },
      "node2": {
        "status": "noresponse"
      }
    },
    "sync_successful": true,
    "sync_nodes_err": [

    ],
    "sync_responses": {
    }
  },
  "log": [
    "I, [2016-04-12T23:27:47.640069 #31527]  INFO -- : PCSD Debugging enabled\n",
    "D, [2016-04-12T23:27:47.640612 #31527] DEBUG -- : Did not detect RHEL 6\n",
    "I, [2016-04-12T23:27:47.640705 #31527]  INFO -- : Running: /usr/sbin/corosync-cmapctl totem.cluster_name\n",
    "I, [2016-04-12T23:27:47.640779 #31527]  INFO -- : CIB USER: hacluster, groups: \n",
    "D, [2016-04-12T23:27:47.644752 #31527] DEBUG -- : []\n",
    "D, [2016-04-12T23:27:47.644958 #31527] DEBUG -- : Duration: 0.003927199s\n",
    "I, [2016-04-12T23:27:47.645148 #31527]  INFO -- : Return Value: 1\n",
    "W, [2016-04-12T23:27:47.645429 #31527]  WARN -- : Cannot read config 'corosync.conf' from '/etc/corosync/corosync.conf': No such file or directory - /etc/corosync/corosync.conf\n",
    "I, [2016-04-12T23:27:47.646517 #31527]  INFO -- : SRWT Node: node2 Request: check_auth\n",
    "I, [2016-04-12T23:27:47.648696 #31527]  INFO -- : SRWT Node: node1 Request: check_auth\n",
    "I, [2016-04-12T23:27:47.650378 #31527]  INFO -- : No response from: node2 request: /check_auth, exception: Connection refused - connect(2)\n"
  ]
}
      eof
    end

    let(:status_data) do
      {
          'node1' => 'already_authorized',
          'node2' => 'noresponse',
      }
    end

    it 'can run the pcs custer auth command' do
      subject.expects(:pcs).with('cluster', 'auth', '--debug', '--force', '--local', '-u', 'user', '-p', 'pass', 'node1', 'node2')
      subject.pcs_auth_command(%w(node1 node2), 'user', 'pass', true, true)
    end

    it 'returns only the debug block' do
      subject.expects(:pcs).with('cluster', 'auth', '--debug', '-u', 'user', '-p', 'pass', 'node1', 'node2').returns(sample_output)
      result = subject.pcs_auth_command(%w(node1 node2), 'user', 'pass')
      expect(result).to eq debug_block
    end

    it 'can parse the debug block' do
      expect(subject.pcs_auth_parse debug_block).to eq(status_data)
    end
  end
end
