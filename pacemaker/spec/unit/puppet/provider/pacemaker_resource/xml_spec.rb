require 'spec_helper'
require 'set'

describe Puppet::Type.type(:pacemaker_resource).provider(:xml) do
  let(:resource) do
    Puppet::Type.type(:pacemaker_resource).new(
        name: 'my_resource',
        primitive_class: 'ocf',
        primitive_provider: 'pacemaker',
        primitive_type: 'Dummy',
        provider: :xml,
    )
  end

  let(:provider) do
    resource.provider
  end

  before(:each) do
    provider.stubs(:cluster_debug_report)
    provider.stubs(:primitives).returns primitives_library_data
    puppet_debug_override
  end

  let(:primitives_library_data) do
    {
        'p_rabbitmq-server' =>
            {'name' => 'p_rabbitmq-server-master',
             'class' => 'ocf',
             'id' => 'p_rabbitmq-server',
             'provider' => 'mirantis',
             'type' => 'rabbitmq-server',
             'complex' =>
                 {'id' => 'p_rabbitmq-server-master',
                  'type' => 'master',
                  'meta_attributes' =>
                      {'notify' =>
                           {'id' => 'p_rabbitmq-server-master-meta_attributes-notify',
                            'name' => 'notify',
                            'value' => 'true'},
                       'master-node-max' =>
                           {'id' => 'p_rabbitmq-server-master-meta_attributes-master-node-max',
                            'name' => 'master-node-max',
                            'value' => '1'},
                       'ordered' =>
                           {'id' => 'p_rabbitmq-server-master-meta_attributes-ordered',
                            'name' => 'ordered',
                            'value' => 'false'},
                       'target-role' =>
                           {'id' => 'p_rabbitmq-server-master-meta_attributes-target-role',
                            'name' => 'target-role',
                            'value' => 'Master'},
                       'master-max' =>
                           {'id' => 'p_rabbitmq-server-master-meta_attributes-master-max',
                            'name' => 'master-max',
                            'value' => '1'},
                       'interleave' =>
                           {'id' => 'p_rabbitmq-server-master-meta_attributes-interleave',
                            'name' => 'interleave',
                            'value' => 'true'}}},
             'instance_attributes' =>
                 {'node_port' =>
                      {'id' => 'p_rabbitmq-server-instance_attributes-node_port',
                       'name' => 'node_port',
                       'value' => '5673'}},
             'meta_attributes' =>
                 {'migration-threshold' =>
                      {'id' => 'p_rabbitmq-server-meta_attributes-migration-threshold',
                       'name' => 'migration-threshold',
                       'value' => 'INFINITY'},
                  'failure-timeout' =>
                      {'id' => 'p_rabbitmq-server-meta_attributes-failure-timeout',
                       'name' => 'failure-timeout',
                       'value' => '60s'}},
             'operations' =>
                 {'p_rabbitmq-server-promote-0' =>
                      {'id' => 'p_rabbitmq-server-promote-0',
                       'interval' => '0',
                       'name' => 'promote',
                       'timeout' => '120'},
                  'p_rabbitmq-server-monitor-30' =>
                      {'id' => 'p_rabbitmq-server-monitor-30',
                       'interval' => '30',
                       'name' => 'monitor',
                       'timeout' => '60'},
                  'p_rabbitmq-server-start-0' =>
                      {'id' => 'p_rabbitmq-server-start-0',
                       'interval' => '0',
                       'name' => 'start',
                       'timeout' => '120'},
                  'p_rabbitmq-server-monitor-27' =>
                      {'id' => 'p_rabbitmq-server-monitor-27',
                       'interval' => '27',
                       'name' => 'monitor',
                       'role' => 'Master',
                       'timeout' => '60'},
                  'p_rabbitmq-server-stop-0' =>
                      {'id' => 'p_rabbitmq-server-stop-0',
                       'interval' => '0',
                       'name' => 'stop',
                       'timeout' => '60'},
                  'p_rabbitmq-server-notify-0' =>
                      {'id' => 'p_rabbitmq-server-notify-0',
                       'interval' => '0',
                       'name' => 'notify',
                       'timeout' => '60'},
                  'p_rabbitmq-server-demote-0' =>
                      {'id' => 'p_rabbitmq-server-demote-0',
                       'interval' => '0',
                       'name' => 'demote',
                       'timeout' => '60'}}},
        'p_neutron-dhcp-agent' =>
            {'name' => 'p_neutron-dhcp-agent',
             'class' => 'ocf',
             'id' => 'p_neutron-dhcp-agent',
             'provider' => 'mirantis',
             'type' => 'neutron-agent-dhcp',
             'instance_attributes' =>
                 {'os_auth_url' =>
                      {'id' => 'p_neutron-dhcp-agent-instance_attributes-os_auth_url',
                       'name' => 'os_auth_url',
                       'value' => 'http://10.108.2.2:35357/v2.0'},
                  'amqp_server_port' =>
                      {'id' => 'p_neutron-dhcp-agent-instance_attributes-amqp_server_port',
                       'name' => 'amqp_server_port',
                       'value' => '5673'},
                  'multiple_agents' =>
                      {'id' => 'p_neutron-dhcp-agent-instance_attributes-multiple_agents',
                       'name' => 'multiple_agents',
                       'value' => 'false'},
                  'password' =>
                      {'id' => 'p_neutron-dhcp-agent-instance_attributes-password',
                       'name' => 'password',
                       'value' => '7BqMhboS'},
                  'tenant' =>
                      {'id' => 'p_neutron-dhcp-agent-instance_attributes-tenant',
                       'name' => 'tenant',
                       'value' => 'services'},
                  'username' =>
                      {'id' => 'p_neutron-dhcp-agent-instance_attributes-username',
                       'name' => 'username',
                       'value' => 'undef'}},
             'meta_attributes' =>
                 {'resource-stickiness' =>
                      {'id' => 'p_neutron-dhcp-agent-meta_attributes-resource-stickiness',
                       'name' => 'resource-stickiness',
                       'value' => '1'}},
             'operations' =>
                 {'p_neutron-dhcp-agent-monitor-20' =>
                      {'id' => 'p_neutron-dhcp-agent-monitor-20',
                       'interval' => '20',
                       'name' => 'monitor',
                       'timeout' => '10'},
                  'p_neutron-dhcp-agent-start-0' =>
                      {'id' => 'p_neutron-dhcp-agent-start-0',
                       'interval' => '0',
                       'name' => 'start',
                       'timeout' => '60'},
                  'p_neutron-dhcp-agent-stop-0' =>
                      {'id' => 'p_neutron-dhcp-agent-stop-0',
                       'interval' => '0',
                       'name' => 'stop',
                       'timeout' => '60'}}},
    }
  end

  describe '#retrieve' do
    it 'should determine that primitive exists' do
      resource[:name] = 'p_neutron-dhcp-agent'
      expect(provider.exists?).to eq true
    end

    it 'should determine that primitive does not exist' do
      resource[:name] = 'MISSING'
      expect(provider.exists?).to eq false
    end

    it 'should retrieve a simple resource' do
      resource[:name] = 'p_neutron-dhcp-agent'
      provider.retrieve_data
      data = {
          ensure: :present,
          name: 'p_neutron-dhcp-agent',
          primitive_class: 'ocf',
          primitive_provider: 'mirantis',
          primitive_type: 'neutron-agent-dhcp',
          complex_type: :simple,
          parameters: {
              'os_auth_url' => 'http://10.108.2.2:35357/v2.0',
              'amqp_server_port' => '5673',
              'multiple_agents' => 'false',
              'password' => '7BqMhboS',
              'tenant' => 'services',
              'username' => 'undef'
          },
          metadata: {
              'resource-stickiness' => '1'
          },
          operations: Set.new(
              [
                  {'interval' => '20', 'name' => 'monitor', 'timeout' => '10'},
                  {'interval' => '0', 'name' => 'start', 'timeout' => '60'},
                  {'interval' => '0', 'name' => 'stop', 'timeout' => '60'},
              ]
          )
      }
      expect(provider.property_hash).to eq data
    end

    it 'should retrieve a complex resource' do
      resource[:name] = 'p_rabbitmq-server'
      provider.retrieve_data
      data = {
          ensure: :present,
          name: 'p_rabbitmq-server',
          primitive_class: 'ocf',
          primitive_provider: 'mirantis',
          primitive_type: 'rabbitmq-server',
          complex_type: :master,
          complex_metadata: {
              'ordered' => 'false',
              'interleave' => 'true',
              'master-max' => '1',
              'notify' => 'true',
              'master-node-max' => '1',
              'target-role' => 'Master'
          },
          parameters: {
              'node_port' => '5673'
          },
          metadata: {
              'migration-threshold' => 'INFINITY',
              'failure-timeout' => '60s'
          },
          operations: Set.new(
              [
                  {'name' => 'demote', 'timeout' => '60', 'interval' => '0'},
                  {'name' => 'monitor', 'timeout' => '60', 'interval' => '27', 'role' => 'Master'},
                  {'name' => 'monitor', 'timeout' => '60', 'interval' => '30'},
                  {'name' => 'notify', 'timeout' => '60', 'interval' => '0'},
                  {'name' => 'promote', 'timeout' => '120', 'interval' => '0'},
                  {'name' => 'start', 'timeout' => '120', 'interval' => '0'},
                  {'name' => 'stop', 'timeout' => '60', 'interval' => '0'},
              ]
          ),
      }
      expect(provider.property_hash).to eq data
    end
  end

  describe '#create' do
    it 'should not allow to create a resource without primitive attributes' do
      resource.delete :primitive_class
      provider.create
      expect { provider.flush }.to raise_error(/Primitive class and type should be present/)
    end

    it 'should create a new resource with corresponding members' do
      resource[:primitive_type] = 'Dummy'
      resource[:primitive_provider] = 'pacemaker'
      resource[:primitive_class] = 'ocf'
      resource[:operations] = [
          {
              'interval' => '20',
              'name' => 'monitor'
          },
          {
              'interval' => '10',
              'name' => 'monitor'
          }
      ]
      resource[:parameters] = {
          'a' => '1',
      }
      resource[:complex_type] = 'clone'
      resource[:complex_metadata] = {
          'interleave' => 'true',
      }

      data = <<-eos
<clone id='my_resource-clone'>
  <meta_attributes id='my_resource-clone-meta_attributes'>
    <nvpair id='my_resource-meta_attributes-interleave' name='interleave' value='true'/>
  </meta_attributes>
  <primitive class='ocf' id='my_resource' provider='pacemaker' type='Dummy'>
    <instance_attributes id='my_resource-instance_attributes'>
      <nvpair id='my_resource-instance_attributes-a' name='a' value='1'/>
    </instance_attributes>
    <operations>
      <op id='my_resource-monitor-10' interval='10' name='monitor'/>
      <op id='my_resource-monitor-20' interval='20' name='monitor'/>
    </operations>
  </primitive>
</clone>
      eos
      provider.expects(:wait_for_primitive_create).with data, resource[:name]
      provider.create
      provider.flush
    end
  end

  describe '#update' do
    it 'should update a simple resource' do
      resource[:name] = 'p_neutron-dhcp-agent'
      provider.stubs(:primitives).returns primitives_library_data
      provider.retrieve_data
      data = <<-eos
<primitive class='ocf' id='p_neutron-dhcp-agent' provider='mirantis' type='neutron-agent-dhcp'>
  <instance_attributes id='p_neutron-dhcp-agent-instance_attributes'>
    <nvpair id='p_neutron-dhcp-agent-instance_attributes-amqp_server_port' name='amqp_server_port' value='5673'/>
    <nvpair id='p_neutron-dhcp-agent-instance_attributes-multiple_agents' name='multiple_agents' value='false'/>
    <nvpair id='p_neutron-dhcp-agent-instance_attributes-os_auth_url' name='os_auth_url' value='http://10.108.2.2:35357/v2.0'/>
    <nvpair id='p_neutron-dhcp-agent-instance_attributes-password' name='password' value='7BqMhboS'/>
    <nvpair id='p_neutron-dhcp-agent-instance_attributes-tenant' name='tenant' value='services'/>
    <nvpair id='p_neutron-dhcp-agent-instance_attributes-username' name='username' value='undef'/>
  </instance_attributes>
  <meta_attributes id='p_neutron-dhcp-agent-meta_attributes'>
    <nvpair id='p_neutron-dhcp-agent-meta_attributes-resource-stickiness' name='resource-stickiness' value='1'/>
  </meta_attributes>
  <operations>
    <op id='p_neutron-dhcp-agent-monitor-20' interval='20' name='monitor' timeout='10'/>
    <op id='p_neutron-dhcp-agent-start-0' interval='0' name='start' timeout='60'/>
    <op id='p_neutron-dhcp-agent-stop-0' interval='0' name='stop' timeout='60'/>
  </operations>
</primitive>
      eos
      provider.stubs(:complex_change?).returns false
      provider.expects(:wait_for_primitive_update).with data, resource[:name]
      provider.flush
    end

    it 'should update a complex resource' do
      resource[:name] = 'p_rabbitmq-server'
      provider.stubs(:primitives).returns primitives_library_data
      provider.retrieve_data
      data = <<-eos
<master id='p_rabbitmq-server-master'>
  <meta_attributes id='p_rabbitmq-server-master-meta_attributes'>
    <nvpair id='p_rabbitmq-server-meta_attributes-interleave' name='interleave' value='true'/>
    <nvpair id='p_rabbitmq-server-meta_attributes-master-max' name='master-max' value='1'/>
    <nvpair id='p_rabbitmq-server-meta_attributes-master-node-max' name='master-node-max' value='1'/>
    <nvpair id='p_rabbitmq-server-meta_attributes-notify' name='notify' value='true'/>
    <nvpair id='p_rabbitmq-server-meta_attributes-ordered' name='ordered' value='false'/>
    <nvpair id='p_rabbitmq-server-meta_attributes-target-role' name='target-role' value='Master'/>
  </meta_attributes>
  <primitive class='ocf' id='p_rabbitmq-server' provider='mirantis' type='rabbitmq-server'>
    <instance_attributes id='p_rabbitmq-server-instance_attributes'>
      <nvpair id='p_rabbitmq-server-instance_attributes-node_port' name='node_port' value='5673'/>
    </instance_attributes>
    <meta_attributes id='p_rabbitmq-server-meta_attributes'>
      <nvpair id='p_rabbitmq-server-meta_attributes-failure-timeout' name='failure-timeout' value='60s'/>
      <nvpair id='p_rabbitmq-server-meta_attributes-migration-threshold' name='migration-threshold' value='INFINITY'/>
    </meta_attributes>
    <operations>
      <op id='p_rabbitmq-server-demote-0' interval='0' name='demote' timeout='60'/>
      <op id='p_rabbitmq-server-monitor-27' interval='27' name='monitor' role='Master' timeout='60'/>
      <op id='p_rabbitmq-server-monitor-30' interval='30' name='monitor' timeout='60'/>
      <op id='p_rabbitmq-server-notify-0' interval='0' name='notify' timeout='60'/>
      <op id='p_rabbitmq-server-promote-0' interval='0' name='promote' timeout='120'/>
      <op id='p_rabbitmq-server-start-0' interval='0' name='start' timeout='120'/>
      <op id='p_rabbitmq-server-stop-0' interval='0' name='stop' timeout='60'/>
    </operations>
  </primitive>
</master>
      eos
      provider.stubs(:complex_change?).returns false
      provider.expects(:wait_for_primitive_update).with data, resource[:name]
      provider.flush
    end

    it 'should be able to change from a complex to a simple resource type' do
      resource[:name] = 'p_rabbitmq-server'
      provider.stubs(:primitives).returns primitives_library_data
      provider.retrieve_data
      provider.complex_type = nil
      provider.complex_metadata = nil
      data = <<-eos
<primitive class='ocf' id='p_rabbitmq-server' provider='mirantis' type='rabbitmq-server'>
  <instance_attributes id='p_rabbitmq-server-instance_attributes'>
    <nvpair id='p_rabbitmq-server-instance_attributes-node_port' name='node_port' value='5673'/>
  </instance_attributes>
  <meta_attributes id='p_rabbitmq-server-meta_attributes'>
    <nvpair id='p_rabbitmq-server-meta_attributes-failure-timeout' name='failure-timeout' value='60s'/>
    <nvpair id='p_rabbitmq-server-meta_attributes-migration-threshold' name='migration-threshold' value='INFINITY'/>
  </meta_attributes>
  <operations>
    <op id='p_rabbitmq-server-demote-0' interval='0' name='demote' timeout='60'/>
    <op id='p_rabbitmq-server-monitor-27' interval='27' name='monitor' role='Master' timeout='60'/>
    <op id='p_rabbitmq-server-monitor-30' interval='30' name='monitor' timeout='60'/>
    <op id='p_rabbitmq-server-notify-0' interval='0' name='notify' timeout='60'/>
    <op id='p_rabbitmq-server-promote-0' interval='0' name='promote' timeout='120'/>
    <op id='p_rabbitmq-server-start-0' interval='0' name='start' timeout='120'/>
    <op id='p_rabbitmq-server-stop-0' interval='0' name='stop' timeout='60'/>
  </operations>
</primitive>
      eos
      provider.stubs(:complex_change?).returns true
      provider.expects(:stop_service)
      provider.expects(:wait_for_primitive_remove).with "<master id='p_rabbitmq-server-master'/>\n", resource[:name]
      provider.expects(:wait_for_primitive_create).with data, resource[:name]
      provider.flush
    end
  end

  describe '#destroy' do
    it 'should destroy a complex resource with the corresponding name' do
      resource[:name] = 'p_rabbitmq-server'
      provider.exists?
      provider.expects(:wait_for_primitive_remove).with("<master id='p_rabbitmq-server-master'/>\n", resource[:name])
      provider.expects(:stop_primitive).with('p_rabbitmq-server-master')
      provider.expects(:cleanup_primitive).with('p_rabbitmq-server-master')
      provider.expects(:wait_for_stop).with('p_rabbitmq-server')
      provider.destroy
    end

    it 'should destroy a simple resource with the corresponding name' do
      resource[:name] = 'p_neutron-dhcp-agent'
      provider.exists?
      provider.expects(:wait_for_primitive_remove).with("<primitive id='p_neutron-dhcp-agent'/>\n", resource[:name])
      provider.expects(:stop_primitive).with('p_neutron-dhcp-agent')
      provider.expects(:wait_for_stop).with('p_neutron-dhcp-agent')
      provider.expects(:cleanup_primitive).with('p_neutron-dhcp-agent')
      provider.destroy
    end
  end

  describe '#insync?' do
    simple_parameters = [
        :primitive_class,
        :primitive_provider,
        :primitive_type,
        :parameters,
        :metadata,
        :operations,
    ]

    complex_parameters = simple_parameters + [
        :complex_type,
        :complex_metadata,
    ]

    context 'for a simple primitive' do
      simple_parameters.each do |parameter_name|
        it "should match provided and retrieved data for parameter #{parameter_name}" do
          resource[:name] = 'p_neutron-dhcp-agent'
          provider.stubs(:primitives).returns primitives_library_data
          resource[:primitive_class] = 'ocf'
          resource[:primitive_provider] = 'mirantis'
          resource[:primitive_type] = 'neutron-agent-dhcp'
          resource[:parameters] = {
              'os_auth_url' => 'http://10.108.2.2:35357/v2.0',
              'amqp_server_port' => '5673',
              'multiple_agents' => 'false',
              'password' => '7BqMhboS',
              'tenant' => 'services',
              'username' => 'undef',
          }
          resource[:metadata] = {
              'resource-stickiness' => '1',
          }
          resource[:operations] = [
              {'name' => 'monitor', 'interval' => '20', 'timeout' => '10'},
              {'name' => 'start', 'timeout' => '60'},
              {'name' => 'stop', 'timeout' => '60'},
          ]

          provider.retrieve_data
          parameter_object = resource.parameter parameter_name
          expect(parameter_object.insync? parameter_object.retrieve).to be_truthy
        end
      end
    end

    context 'for a complex primitive' do
      complex_parameters.each do |parameter_name|
        it "should match provided and retrieved data for parameter #{parameter_name}" do
          resource[:name] = 'p_rabbitmq-server'
          provider.stubs(:primitives).returns primitives_library_data
          resource[:primitive_class] = 'ocf'
          resource[:primitive_provider] = 'mirantis'
          resource[:primitive_type] = 'rabbitmq-server'
          resource[:complex_type] = 'master'
          resource[:complex_metadata] = {
              'notify' => 'true',
              'master-node-max' => '1',
              'ordered' => 'false',
              'target-role' => 'Master',
              'master-max' => '1',
              'interleave' => 'true'
          }
          resource[:parameters] = {
              'node_port' => '5673',
          }
          resource[:metadata] = {
              'migration-threshold' => 'INFINITY',
              'failure-timeout' => '60s',
          }
          resource[:operations] = [
              {'interval' => '0', 'name' => 'promote', 'timeout' => '120'},
              {'interval' => '30', 'name' => 'monitor', 'timeout' => '60'},
              {'interval' => '0', 'name' => 'start', 'timeout' => '120'},
              {'interval' => '27', 'name' => 'monitor', 'role' => 'Master', 'timeout' => '60'},
              {'interval' => '0', 'name' => 'stop', 'timeout' => '60'},
              {'interval' => '0', 'name' => 'notify', 'timeout' => '60'},
              {'interval' => '0', 'name' => 'demote', 'timeout' => '60'},
          ]

          provider.retrieve_data
          parameter_object = resource.parameter parameter_name
          expect(parameter_object.insync? parameter_object.retrieve).to be_truthy
        end
      end
    end
  end
end
