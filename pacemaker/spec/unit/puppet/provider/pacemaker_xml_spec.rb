require 'spec_helper'

require_relative '../../../../lib/puppet/provider/pacemaker_xml'

describe Puppet::Provider::PacemakerXML do
  cib_xml_file = File.join File.dirname(__FILE__), 'cib.xml'

  let(:raw_cib) do
    File.read cib_xml_file
  end

  let(:resources_regexp) do
    /nova|cinder|glance|keystone|neutron|sahara|murano|ceilometer|heat|swift/
  end

  before(:each) do
    puppet_debug_override
    subject.stubs(:wait_for_online).returns(true)
    subject.pacemaker_options[:retry_step] = 0
  end

  let :location_data do
    {
        'vip__public-on-node-1' =>
            {
                'score' => '100',
                'rsc' => 'vip__public',
                'id' => 'vip__public-on-node-1',
                'node' => 'node-1'
            },
        'loc_ping_vip__public' =>
            {
                'rsc' => 'vip__public',
                'id' => 'loc_ping_vip__public',
                'rules' => [
                    {
                        'score' => '-INFINITY',
                        'id' => 'loc_ping_vip__public-rule',
                        'boolean-op' => 'or',
                        'expressions' => [
                            {
                                'attribute' => 'pingd',
                                'id' => 'loc_ping_vip__public-expression',
                                'operation' => 'not_defined'
                            },
                            {
                                'attribute' => 'pingd',
                                'id' => 'loc_ping_vip__public-expression-0',
                                'operation' => 'lte', 'value' => '0'
                            },
                        ]
                    }
                ],
            },
    }
  end

  let :colocation_data do
    {
        'vip_management-with-haproxy' => {
            'rsc' => 'vip__management',
            'score' => 'INFINITY',
            'with-rsc' => 'p_haproxy-clone',
            'id' => 'vip_management-with-haproxy',
        }
    }
  end

  let :order_data do
    {
        'p_neutron-dhcp-agent-after-p_neutron-plugin-openvswitch-agent-clone' => {
            'first' => 'p_neutron-plugin-openvswitch-agent-clone',
            'id' => 'p_neutron-dhcp-agent-after-p_neutron-plugin-openvswitch-agent-clone',
            'score' => 'INFINITY',
            'then' => 'p_neutron-dhcp-agent',
        },
        'order-test1-test2-Mandatory' => {
            'first'=>'test1',
            'first-action'=>'promote',
            'id'=>'order-test1-test2-Mandatory',
            'kind'=>'Mandatory',
            'symmetrical'=>'true',
            'then'=>'test2',
            'then-action'=>'start',
        },
    }
  end

  let(:primitive_data) do
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
                       'timeout' => '60',
                       'OCF_CHECK_LEVEL' => '30'},
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

  ###########################

  before(:each) do
    subject.stubs(:raw_cib).returns raw_cib
  end

  context '#configuration' do
    it 'can obtain a CIB XML object' do
      expect(subject.cib.to_s).to include '<configuration>'
      expect(subject.cib.to_s).to include '<nodes>'
      expect(subject.cib.to_s).to include '<resources>'
      expect(subject.cib.to_s).to include '<status>'
      expect(subject.cib.to_s).to include '<operations>'
    end

    it 'can get primitives section of CIB XML' do
      expect(subject.cib_section_primitives).to be_a(Array)
      expect(subject.cib_section_primitives.first.to_s).to start_with '<primitive'
      expect(subject.cib_section_primitives.first.to_s).to end_with '</primitive>'
    end

    it 'can get primitives configuration' do
      expect(subject.primitives).to be_a Hash
      expect(subject.primitives['vip__public']).to be_a Hash
      expect(subject.primitives['vip__public']['meta_attributes']).to be_a Hash
      expect(subject.primitives['vip__public']['instance_attributes']).to be_a Hash
      expect(subject.primitives['vip__public']['instance_attributes']['ip']).to be_a Hash
      expect(subject.primitives['vip__public']['operations']).to be_a Hash
      expect(subject.primitives['vip__public']['meta_attributes']['resource-stickiness']).to be_a Hash
      expect(subject.primitives['vip__public']['operations']['vip__public-start-0']).to be_a Hash
    end

    it 'can determine if primitive is simple or complex' do
      expect(subject.primitive_is_complex? 'p_haproxy').to eq true
      expect(subject.primitive_is_complex? 'vip__management').to eq false
    end
  end

  context '#status' do
    it 'can produce nodes structure' do
      expect(subject.node_status).to be_a Hash
      expect(subject.node_status['node-1']['primitives']['p_heat-engine']['status']).to eq('start')
    end

    it 'can generate a debug output' do
      report = <<-eof

Pacemaker debug block start at 'test'
-> Clone primitive: 'p_neutron-plugin-openvswitch-agent-clone'
   node-1: START (L) | node-2: STOP | node-3: STOP
-> Simple primitive: 'p_ceilometer-alarm-evaluator'
   node-1: STOP | node-2: STOP (F) | node-3: STOP (F)
-> Simple primitive: 'p_heat-engine'
   node-1: START (L) | node-2: STOP | node-3: STOP
-> Simple primitive: 'p_ceilometer-agent-central' (M)
   node-1: STOP | node-2: STOP (F) | node-3: STOP (F)
-> Simple primitive: 'vip__management'
   node-1: START (L) | node-2: STOP (L) | node-3: STOP (L)
-> Clone primitive: 'ping_vip__public-clone'
   node-1: START (L) | node-2: START (L) | node-3: START (L)
-> Clone primitive: 'p_neutron-l3-agent-clone'
   node-1: START (L) | node-2: STOP | node-3: STOP
-> Clone primitive: 'p_neutron-metadata-agent-clone'
   node-1: START (L) | node-2: STOP | node-3: STOP
-> Clone primitive: 'p_mysql-clone'
   node-1: START (L) | node-2: START (L) | node-3: STOP
-> Simple primitive: 'p_neutron-dhcp-agent'
   node-1: START (L) | node-2: STOP | node-3: STOP
-> Simple primitive: 'vip__public'
   node-1: START (L) | node-2: STOP (L) | node-3: STOP (L)
-> Clone primitive: 'p_haproxy-clone'
   node-1: START (L) | node-2: START (L) | node-3: STOP
-> Master primitive: 'p_rabbitmq-server-master'
   node-1: MASTER (L) | node-2: START (L) | node-3: STOP
* symmetric-cluster: false
* no-quorum-policy: ignore
Pacemaker debug block end at 'test'
      eof
      subject.stubs(:cib?).returns(true)
      debug = subject.cluster_debug_report 'test'
      expect(debug).to eq report
    end

    it 'can determine the id of the DC node' do
      expect(subject.dc).to eq '1'
    end

    it 'can determine the name of the DC node' do
      expect(subject.dc_name).to eq 'node-1'
    end

    it 'can determine the global primitive status' do
      expect(subject.primitive_status 'p_heat-engine').to eq('start')
      expect(subject.primitive_is_running? 'p_heat-engine').to eq true
      expect(subject.primitive_status 'p_ceilometer-agent-central').to eq('stop')
      expect(subject.primitive_is_running? 'p_ceilometer-agent-central').to eq false
      expect(subject.primitive_is_running? 'UNKNOWN').to eq nil
      expect(subject.primitive_status 'UNKNOWN').to eq nil
    end

    it 'can determine the local primitive status on a node' do
      expect(subject.primitive_status 'p_heat-engine', 'node-1').to eq('start')
      expect(subject.primitive_is_running? 'p_heat-engine', 'node-1').to eq true
      expect(subject.primitive_status 'p_heat-engine', 'node-2').to eq('stop')
      expect(subject.primitive_is_running? 'p_heat-engine', 'node-2').to eq false
      expect(subject.primitive_is_running? 'UNKNOWN', 'node-1').to eq nil
      expect(subject.primitive_status 'UNKNOWN', 'node-1').to eq nil
    end

    it 'can get the list of nodes where the primitive has the given status' do
      expect(subject.primitive_has_status_on 'p_heat-engine', 'start').to eq(%w(node-1))
      expect(subject.primitive_has_status_on 'p_heat-engine', 'stop').to eq(%w(node-2 node-3))
      expect(subject.primitive_has_status_on 'p_heat-engine', 'master').to eq(%w())
    end

    it 'can determine if primitive is managed or not' do
      expect(subject.primitive_is_managed? 'p_heat-engine').to eq true
      expect(subject.primitive_is_managed? 'p_haproxy').to eq true
      expect(subject.primitive_is_managed? 'UNKNOWN').to eq nil
    end

    it 'can determine if primitive is started or not' do
      expect(subject.primitive_is_started? 'p_heat-engine').to eq true
      expect(subject.primitive_is_started? 'p_haproxy').to eq true
      expect(subject.primitive_is_started? 'UNKNOWN').to eq nil
    end

    it 'can determine if primitive is failed or not globally' do
      expect(subject.primitive_has_failures? 'p_ceilometer-agent-central').to eq true
      expect(subject.primitive_has_failures? 'p_heat-engine').to eq false
      expect(subject.primitive_has_failures? 'UNKNOWN').to eq nil
    end

    it 'can determine if primitive is failed or not locally' do
      expect(subject.primitive_has_failures? 'p_ceilometer-agent-central', 'node-1').to eq false
      expect(subject.primitive_has_failures? 'p_ceilometer-agent-central', 'node-2').to eq true
      expect(subject.primitive_has_failures? 'p_heat-engine', 'node-1').to eq false
      expect(subject.primitive_has_failures? 'p_heat-engine', 'node-2').to eq false
      expect(subject.primitive_has_failures? 'UNKNOWN', 'node-1').to eq nil
    end

    it 'can determine that primitive is complex' do
      expect(subject.primitive_is_complex? 'p_haproxy').to eq true
      expect(subject.primitive_is_complex? 'p_heat-engine').to eq false
      expect(subject.primitive_is_complex? 'p_rabbitmq-server').to eq true
      expect(subject.primitive_is_complex? 'UNKNOWN').to eq nil
    end

    it 'can determine that primitive is master' do
      expect(subject.primitive_is_master? 'p_haproxy').to eq false
      expect(subject.primitive_is_master? 'p_heat-engine').to eq false
      expect(subject.primitive_is_master? 'p_rabbitmq-server').to eq true
      expect(subject.primitive_is_master? 'UNKNOWN').to eq nil
    end

    it 'can determine that primitive has master running' do
      expect(subject.primitive_has_master_running? 'p_rabbitmq-server').to eq true
      expect(subject.primitive_has_master_running? 'p_heat-engine').to eq false
      expect(subject.primitive_has_master_running? 'UNKNOWN').to eq nil
    end

    it 'can determine that primitive is clone' do
      expect(subject.primitive_is_clone? 'p_haproxy').to eq true
      expect(subject.primitive_is_clone? 'p_heat-engine').to eq false
      expect(subject.primitive_is_clone? 'p_rabbitmq-server').to eq false
      expect(subject.primitive_is_clone? 'UNKNOWN').to eq nil
    end
  end

  context '#properties' do
    it 'can get cluster property value' do
      expect(subject.cluster_property_value 'no-quorum-policy').to eq 'ignore'
      expect(subject.cluster_property_value 'UNKNOWN').to be_nil
    end

    it 'can set cluster property value' do
      subject.expects(:crm_attribute).returns true
      subject.cluster_property_set 'no-quorum-policy', 'ignore'
    end

    it 'can delete cluster property value' do
      subject.expects(:crm_attribute).returns true
      subject.cluster_property_delete 'no-quorum-policy'
    end

    it 'can determine if a property is defined' do
      expect(subject.cluster_property_defined? 'no-quorum-policy').to eq(true)
      expect(subject.cluster_property_defined? 'UNKNOWN').to eq(false)
    end
  end

  context '#constraints' do
    it 'can generate a joined constraints structure' do
      expect(subject.constraints).to be_a(Hash)
      expect(subject.constraints['p_heat-engine-on-node-1']).to be_a(Hash)
      expect(subject.constraints['p_heat-engine-on-node-1']['rsc']).to be_a String
      expect(subject.constraints['p_heat-engine-on-node-1']).to be_a(Hash)
      expect(subject.constraints['vip_management-with-haproxy']['with-rsc']).to be_a String
      expect(subject.constraints['p_neutron-dhcp-agent-after-p_neutron-plugin-openvswitch-agent-clone']).to be_a(Hash)
      expect(subject.constraints['p_neutron-dhcp-agent-after-p_neutron-plugin-openvswitch-agent-clone']['first']).to be_a String
    end

    it 'can check if a constraint of any types exists' do
      expect(subject.constraint_exists? 'UNKNOWN').to eq(false)
      expect(subject.constraint_exists? 'p_heat-engine-on-node-1').to eq(true)
      expect(subject.constraint_exists? 'p_heat-engine-on-node-1').to eq(true)
      expect(subject.constraint_exists? 'p_neutron-dhcp-agent-after-p_neutron-plugin-openvswitch-agent-clone').to eq(true)
    end

    context '#location' do
      it 'can get the location structure from the CIB XML' do
        expect(subject.constraint_locations).to be_a(Hash)
        expect(subject.constraint_locations['p_heat-engine-on-node-1']).to be_a(Hash)
        expect(subject.constraint_locations['p_heat-engine-on-node-1']['rsc']).to be_a String
      end

      let(:location_structure) {
        {
            'id' => 'test-on-node1',
            'node' => 'node1',
            'rsc' => 'test',
            'score' => '100',
        }
      }

      let(:location_xml) {
        <<-eof
<rsc_location id='test-on-node1' node='node1' rsc='test' score='100'/>
        eof
      }

      let(:location_remove_xml) {
        <<-eof
<rsc_location id='test-on-node1'/>
        eof
      }

      it 'can add a location constraint' do
        subject.expects(:wait_for_constraint_create).with location_xml, location_structure['id']
        subject.constraint_location_add location_structure
      end

      it 'can check if a location constraint exists' do
        expect(subject.constraint_location_exists? 'p_heat-engine-on-node-1').to eq(true)
        expect(subject.constraint_location_exists? 'UNKNOWN').to eq(false)
      end

      it 'can remove a location constraint' do
        subject.expects(:wait_for_constraint_remove).with location_remove_xml, location_structure['id']
        subject.constraint_location_remove 'test-on-node1'
      end

      it 'can add a service location constraint' do
        subject.expects(:wait_for_constraint_create).with location_xml, location_structure['id']
        subject.service_location_add 'test', 'node1', '100'
      end

      it 'can check if a service location constraint exists' do
        expect(subject.service_location_exists?('test', 'node1')).to eq(false)
        expect(subject.service_location_exists?('p_heat-engine', 'node-1')).to eq(true)
      end
    end

    context '#colocation' do
      let(:colocation_structure) {
        {
            'id' => 'test1-with-test2',
            'rsc' => 'test1',
            'with-rsc' => 'test2',
            'score' => '100',
        }
      }

      let(:colocation_xml) {
        <<-eof
<rsc_colocation id='test1-with-test2' rsc='test1' score='100' with-rsc='test2'/>
        eof
      }

      let(:colocation_remove_xml) {
        <<-eof
<rsc_colocation id='test1-with-test2'/>
        eof
      }

      it 'can get the colocation structure from the CIB XML' do
        expect(subject.constraint_colocations).to be_a(Hash)
        expect(subject.constraint_colocations['vip_management-with-haproxy']).to be_a(Hash)
        expect(subject.constraint_colocations['vip_management-with-haproxy']['with-rsc']).to be_a String
      end

      it 'can add a colocation constraint' do
        subject.expects(:wait_for_constraint_create).with colocation_xml, colocation_structure['id']
        subject.constraint_colocation_add colocation_structure
      end

      it 'can check if a colocation constraint exists' do
        expect(subject.constraint_colocation_exists? 'vip_management-with-haproxy').to eq(true)
        expect(subject.constraint_colocation_exists? 'UNKNOWN').to eq(false)
      end

      it 'can remove a colocation constraint' do
        subject.expects(:wait_for_constraint_remove).with colocation_remove_xml, colocation_structure['id']
        subject.constraint_colocation_remove 'test1-with-test2'
      end
    end

    context '#order' do
      let(:order_score_structure) {
        {
            'id' => 'test1-after-test2',
            'first' => 'test2',
            'then' => 'test1',
            'score' => '100',
        }
      }

      let(:order_kind_structure) {
        {
            'id' => 'test1-after-test2',
            'first' => 'test2',
            'then' => 'test1',
            'kind' => 'Mandatory',
            'first-action' => 'promote',
            'second-action' => 'demote',
            'require-all' => 'false',
            'symmetrical' => 'false',
        }
      }

      let(:order_score_xml) {
        <<-eof
<rsc_order first='test2' id='test1-after-test2' score='100' then='test1'/>
        eof
      }

      let(:order_kind_xml) {
        <<-eof
<rsc_order first='test2' first-action='promote' id='test1-after-test2' kind='Mandatory' require-all='false' second-action='demote' symmetrical='false' then='test1'/>
        eof
      }

      let(:order_remove_xml) {
        <<-eof
<rsc_order id='test1-after-test2'/>
        eof
      }

      it 'can get the order structure from the CIB XML' do
        expect(subject.constraint_orders).to be_a(Hash)
        expect(subject.constraint_orders['p_neutron-dhcp-agent-after-p_neutron-plugin-openvswitch-agent-clone']).to be_a(Hash)
        expect(subject.constraint_orders['p_neutron-dhcp-agent-after-p_neutron-plugin-openvswitch-agent-clone']['first']).to be_a String
        expect(subject.constraint_orders['p_neutron-dhcp-agent-after-p_neutron-plugin-openvswitch-agent-clone']['score']).to be_a String
        expect(subject.constraint_orders['order-test1-test2-Mandatory']).to be_a(Hash)
        expect(subject.constraint_orders['order-test1-test2-Mandatory']['first']).to be_a String
        expect(subject.constraint_orders['order-test1-test2-Mandatory']['kind']).to be_a String
      end

      it 'can add an order constraint with score' do
        subject.expects(:wait_for_constraint_create).with order_score_xml, order_score_structure['id']
        subject.constraint_order_add order_score_structure
      end

      it 'can add an order constraint with kind' do
        subject.expects(:wait_for_constraint_create).with order_kind_xml, order_kind_structure['id']
        subject.constraint_order_add order_kind_structure
      end

      it 'can check if an order constraint exists' do
        expect(subject.constraint_order_exists? 'p_neutron-dhcp-agent-after-p_neutron-plugin-openvswitch-agent-clone').to eq(true)
        expect(subject.constraint_order_exists? 'UNKNOWN').to eq(false)
      end

      it 'can remove an order constraint with score' do
        subject.expects(:wait_for_constraint_remove).with order_remove_xml, order_score_structure['id']
        subject.constraint_order_remove 'test1-after-test2'
      end

      it 'can remove an order constraint with kind' do
        subject.expects(:wait_for_constraint_remove).with order_remove_xml, order_kind_structure['id']
        subject.constraint_order_remove 'test1-after-test2'
      end
    end
  end

  context '#retry_functions' do
    before(:each) do
      subject.stubs(:cib_reset).returns true
    end

    context '#generic' do
      it 'retries block until it becomes true' do
        subject.retry_block { true }
      end

      it 'waits for Pacemaker to become ready' do
        subject.stubs(:online?).returns true
        subject.wait_for_online
      end

      it 'waits for status to become known' do
        subject.stubs(:primitive_status).returns 'stopped'
        subject.wait_for_status 'myprimitive'
      end
    end

    context '#service' do
      it 'waits for the service to start' do
        subject.stubs(:primitive_is_running?).with('myprimitive', nil).returns true
        subject.wait_for_start 'myprimitive'
      end

      it 'waits for the service to stop' do
        subject.stubs(:primitive_is_running?).with('myprimitive', nil).returns false
        subject.wait_for_stop 'myprimitive'
      end
    end

    context '#primitive' do
      it 'waits for a primitive to be created' do
        subject.stubs(:primitive_exists?).with('test').returns(true)
        subject.expects(:cibadmin_create).never
        subject.wait_for_primitive_create 'xml', 'test'
        subject.stubs(:primitive_exists?).with('test').returns(false, true)
        subject.expects(:cibadmin_create).with('xml', 'resources')
        subject.wait_for_primitive_create 'xml', 'test'
      end

      it 'waits for a primitive to be updated' do
        subject.expects(:cibadmin_replace).with('xml', 'resources').returns(false, true).twice
        subject.wait_for_primitive_update 'xml', 'test'
      end

      it 'waits for a primitive to be removed' do
        subject.stubs(:primitive_exists?).with('test').returns(false)
        subject.expects(:cibadmin_delete).never
        subject.wait_for_primitive_remove 'xml', 'test'
        subject.stubs(:primitive_exists?).with('test').returns(true, false)
        subject.expects(:cibadmin_delete).with('xml', 'resources')
        subject.wait_for_primitive_remove 'xml', 'test'
      end
    end

    context '#constraint' do
      it 'waits for a constraint to be created' do
        subject.stubs(:constraint_exists?).with('test').returns(true)
        subject.expects(:cibadmin_create).never
        subject.wait_for_constraint_create 'xml', 'test'
        subject.stubs(:constraint_exists?).with('test').returns(false, true)
        subject.expects(:cibadmin_create).with('xml', 'constraints')
        subject.wait_for_constraint_create 'xml', 'test'
      end

      it 'waits for a constraint to be updated' do
        subject.expects(:cibadmin_replace).with('xml', 'constraints').returns(false, true).twice
        subject.wait_for_constraint_update 'xml', 'test'
      end

      it 'waits for a constraint to be removed' do
        subject.stubs(:constraint_exists?).with('test').returns(false)
        subject.expects(:cibadmin_delete).never
        subject.wait_for_constraint_remove 'xml', 'test'
        subject.stubs(:constraint_exists?).with('test').returns(true, false)
        subject.expects(:cibadmin_delete).with('xml', 'constraints')
        subject.wait_for_constraint_remove 'xml', 'test'
      end
    end
  end

  context '#xml_generation' do
    it 'can create a new XML document with the specified path' do
      doc = subject.xml_document %w(a b c)
      expect(doc).to be_a(REXML::Element)
      expect(doc.to_s).to eq('<c/>')
      expect(doc.root.to_s).to eq('<a><b><c/></b></a>')
    end

    it 'can format an xml element' do
      element = REXML::Element.new 'test'
      element.add_attribute 'a', 1
      element.add_attribute 'b', 2
      child = element.add_element 'c'
      child.add_attribute 'd', 3
      xml = <<-eos
<test a='1' b='2'>
  <c d='3'/>
</test>
      eos
      expect(subject.xml_pretty_format element).to eq(xml)
    end

    it 'can create a new element using the existing document' do
      doc = REXML::Document.new
      doc = doc.add_element 'a'
      element = subject.xml_document 'b', doc
      expect(element).to be_a(REXML::Element)
      expect(element.to_s).to eq('<b/>')
      expect(element.root.to_s).to eq('<a><b/></a>')
    end

    it 'can create a new xml element from a hash' do
      hash = {'a' => '1', 'b' => 2, 'c' => :d, :e => [1, 2, 3], :f => {g: 1, h: 2}, 'o' => 'skip'}
      element = subject.xml_element 'test', hash, 'o'
      expect(element.to_s).to eq("<test a='1' b='2' c='d'/>")
    end

    it 'can create an xml element from a simple rsc_location data structure' do
      data = location_data['vip__public-on-node-1']
      location = subject.xml_rsc_location data
      xml = <<-eos
<rsc_location id='vip__public-on-node-1' node='node-1' rsc='vip__public' score='100'/>
      eos
      expect(subject.xml_pretty_format location).to eq(xml)
    end

    context 'location' do
      it 'can create an xml element from a rule based rsc_location structure' do
        data = location_data['loc_ping_vip__public']
        location = subject.xml_rsc_location data
        xml = <<-eos
<rsc_location id='loc_ping_vip__public' rsc='vip__public'>
  <rule boolean-op='or' id='loc_ping_vip__public-rule' score='-INFINITY'>
    <expression attribute='pingd' id='loc_ping_vip__public-expression' operation='not_defined'/>
    <expression attribute='pingd' id='loc_ping_vip__public-expression-0' operation='lte' value='0'/>
  </rule>
</rsc_location>
        eos
        expect(subject.xml_pretty_format location).to eq(xml)
      end

      it 'can match a generated and a parsed XML to the original data for a rule based location' do
        original_data = location_data['loc_ping_vip__public']
        require 'pp'
        generated_location_element = subject.xml_rsc_location original_data
        decoded_data = subject.decode_constraint generated_location_element
        decoded_data.delete 'type'
        expect(original_data).to eq(decoded_data)
      end

      it 'can match a generated and a parsed XML to the original data for a simple location' do
        original_data = location_data['vip__public-on-node-1']
        generated_location_element = subject.xml_rsc_location original_data
        decoded_data = subject.decode_constraint generated_location_element
        decoded_data.delete 'type'
        expect(original_data).to eq(decoded_data)
      end
    end

    context 'colocation' do
      it 'can create an XML element from a rsc_colocation structure' do
        data = colocation_data['vip_management-with-haproxy']
        colocation = subject.xml_rsc_colocation data
        xml = <<-eos
<rsc_colocation id='vip_management-with-haproxy' rsc='vip__management' score='INFINITY' with-rsc='p_haproxy-clone'/>
        eos
        expect(subject.xml_pretty_format colocation).to eq(xml)
      end

      it 'can match a generated and a parsed XML to the original data for a colocation' do
        original_data = colocation_data['vip_management-with-haproxy']
        generated_colocation_element = subject.xml_rsc_colocation original_data
        decoded_data = subject.decode_constraint generated_colocation_element
        decoded_data.delete 'type'
        expect(original_data).to eq(decoded_data)
      end
    end

    context 'order' do
      it 'can create an XML element with score from a rsc_order structure' do
        data = order_data['p_neutron-dhcp-agent-after-p_neutron-plugin-openvswitch-agent-clone']
        order = subject.xml_rsc_order data
        xml = <<-eos
<rsc_order first='p_neutron-plugin-openvswitch-agent-clone' id='p_neutron-dhcp-agent-after-p_neutron-plugin-openvswitch-agent-clone' score='INFINITY' then='p_neutron-dhcp-agent'/>
        eos
        expect(subject.xml_pretty_format order).to eq(xml)
      end

      it 'can create an XML element with kind from a rsc_order structure' do
        data = order_data['order-test1-test2-Mandatory']
        order = subject.xml_rsc_order data
        xml = <<-eos
<rsc_order first='test1' first-action='promote' id='order-test1-test2-Mandatory' kind='Mandatory' symmetrical='true' then='test2' then-action='start'/>
        eos
        expect(subject.xml_pretty_format order).to eq(xml)
      end

      it 'can match a generated and a parsed XML to the original data for an order with score' do
        original_data = order_data['p_neutron-dhcp-agent-after-p_neutron-plugin-openvswitch-agent-clone']
        generated_order_element = subject.xml_rsc_colocation original_data
        decoded_data = subject.decode_constraint generated_order_element
        decoded_data.delete 'type'
        expect(original_data).to eq(decoded_data)
      end

      it 'can match a generated and a parsed XML to the original data for an order with kind' do
        original_data = order_data['order-test1-test2-Mandatory']
        generated_order_element = subject.xml_rsc_colocation original_data
        decoded_data = subject.decode_constraint generated_order_element
        decoded_data.delete 'type'
        expect(original_data).to eq(decoded_data)
      end
    end

    context 'primitive' do
      it 'can create an XML element from a simple primitive structure' do
        data = primitive_data['p_neutron-dhcp-agent']
        primitive_element = subject.xml_primitive data
        xml = <<-eos
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
        expect(subject.xml_pretty_format primitive_element).to eq(xml)
      end

      it 'can create an XML element from a complex primitive structure' do
        data = primitive_data['p_rabbitmq-server']
        primitive_element = subject.xml_primitive data
        xml = <<-eos
<master id='p_rabbitmq-server-master'>
  <meta_attributes id='p_rabbitmq-server-master-meta_attributes'>
    <nvpair id='p_rabbitmq-server-master-meta_attributes-interleave' name='interleave' value='true'/>
    <nvpair id='p_rabbitmq-server-master-meta_attributes-master-max' name='master-max' value='1'/>
    <nvpair id='p_rabbitmq-server-master-meta_attributes-master-node-max' name='master-node-max' value='1'/>
    <nvpair id='p_rabbitmq-server-master-meta_attributes-notify' name='notify' value='true'/>
    <nvpair id='p_rabbitmq-server-master-meta_attributes-ordered' name='ordered' value='false'/>
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
      <op id='p_rabbitmq-server-monitor-30' interval='30' name='monitor' timeout='60'>
        <instance_attributes id='p_rabbitmq-server-monitor-30-instance_attributes'>
          <nvpair id='p_rabbitmq-server-monitor-30-instance_attributes-OCF_CHECK_LEVEL' name='OCF_CHECK_LEVEL' value='30'/>
        </instance_attributes>
      </op>
      <op id='p_rabbitmq-server-notify-0' interval='0' name='notify' timeout='60'/>
      <op id='p_rabbitmq-server-promote-0' interval='0' name='promote' timeout='120'/>
      <op id='p_rabbitmq-server-start-0' interval='0' name='start' timeout='120'/>
      <op id='p_rabbitmq-server-stop-0' interval='0' name='stop' timeout='60'/>
    </operations>
  </primitive>
</master>
        eos
        expect(subject.xml_pretty_format primitive_element).to eq(xml)
      end

      it 'can match a generated and a parsed XML to the original data for a simple primitive' do
        original_data = primitive_data['p_neutron-dhcp-agent']
        generated_primitive_element = subject.xml_primitive original_data
        subject.stubs(:raw_cib).returns subject.xml_pretty_format(generated_primitive_element)
        parsed_data = subject.primitives['p_neutron-dhcp-agent']
        expect(parsed_data).to eq original_data
      end

      it 'can match a generated and a parsed XML to the original data for a complex primitive' do
        original_data = primitive_data['p_rabbitmq-server']
        generated_primitive_element = subject.xml_primitive original_data
        subject.stubs(:raw_cib).returns subject.xml_pretty_format(generated_primitive_element)
        parsed_data = subject.primitives['p_rabbitmq-server']
        expect(parsed_data).to eq original_data
      end
    end
  end
end
