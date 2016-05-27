require 'spec_helper'

describe Puppet::Type.type(:pacemaker_location).provider(:xml) do
  let(:resource) do
    Puppet::Type.type(:pacemaker_location).new(
        name: 'my_location',
        ensure: :present,
        primitive: 'my_primitive',
        node: 'my_node',
        provider: :xml,
        score: '200',
    )
  end

  let(:provider) do
    resource.provider
  end

  before(:each) do
    puppet_debug_override
    provider.stubs(:cluster_debug_report).returns(true)
    provider.stubs(:primitive_exists?).with('my_primitive').returns(true)
  end

  describe('#validation') do
    it 'should fail if there is no primitive in the CIB' do
      provider.stubs(:primitive_exists?).with('my_primitive').returns(false)
      provider.create
      expect { provider.flush }.to raise_error "Primitive 'my_primitive' does not exist!"
    end

    it 'should fail if there are neither rules nor node and score set' do
      provider.create
      provider.rules = nil
      provider.node = nil
      provider.score = nil
      expect { provider.flush }.to raise_error 'Data does not contain all the required fields!'
    end
  end

  context '#create' do
    it 'should create a simple location' do
      xml = <<-eos
<rsc_location id='my_location' node='my_node' rsc='my_primitive' score='200'/>
      eos
      provider.expects(:wait_for_constraint_create).with xml, resource[:name]
      provider.create
      provider.flush
    end

    it 'should create location with rule' do
      resource.delete :node
      resource.delete :score
      resource[:rules] = [
          {
              score: 'inf',
              expressions: [
                  {
                      attribute: 'pingd1',
                      operation: 'defined',
                  },
                  {
                      attribute: 'pingd2',
                      operation: 'defined',
                  }
              ]
          }
      ]

      xml = <<-eos
<rsc_location id='my_location' rsc='my_primitive'>
  <rule boolean-op='or' id='my_location-rule-0' score='INFINITY'>
    <expression attribute='pingd1' id='my_location-rule-0-expression-0' operation='defined'/>
    <expression attribute='pingd2' id='my_location-rule-0-expression-1' operation='defined'/>
  </rule>
</rsc_location>
      eos

      provider.expects(:wait_for_constraint_create).with xml, resource[:name]
      provider.create
      provider.flush
    end

    it 'should create location with several rules' do
      resource.delete :node
      resource.delete :score
      resource[:rules] = [
          {
              score: 'inf',
              expressions: [
                  {
                      attribute: 'pingd1',
                      operation: 'defined',
                  }
              ]
          },
          {
              score: 'inf',
              expressions: [
                  {
                      attribute: 'pingd2',
                      operation: 'defined',
                  }
              ]
          }
      ]

      xml = <<-eos
<rsc_location id='my_location' rsc='my_primitive'>
  <rule boolean-op='or' id='my_location-rule-0' score='INFINITY'>
    <expression attribute='pingd1' id='my_location-rule-0-expression-0' operation='defined'/>
  </rule>
  <rule boolean-op='or' id='my_location-rule-1' score='INFINITY'>
    <expression attribute='pingd2' id='my_location-rule-1-expression-0' operation='defined'/>
  </rule>
</rsc_location>
      eos
      provider.expects(:wait_for_constraint_create).with xml, resource[:name]
      provider.create
      provider.flush
    end
  end

  context '#update' do
    it 'should update a simple location' do
      xml = <<-eos
<rsc_location id='my_location' node='my_node' rsc='my_primitive' score='200'/>
      eos
      provider.expects(:wait_for_constraint_update).with xml, resource[:name]
      provider.create
      provider.property_hash[:ensure] = :present
      provider.flush
    end
  end

  context '#exists' do
    it 'detects an existing location' do
      provider.stubs(:constraint_locations).returns(
          'my_location' => {
              'rsc' => 'my_resource',
              'node' => 'my_node',
              'score' => '100',
          }
      )
      expect(provider.exists?).to be_truthy
      provider.stubs(:constraint_locations).returns(
          'other_location' => {
              'rsc' => 'other_resource',
              'node' => 'other_node',
              'score' => '100',
          }
      )
      expect(provider.exists?).to be_falsey
      provider.stubs(:constraint_locations).returns({})
      expect(provider.exists?).to be_falsey
    end

    it 'loads the current resource state' do
      provider.stubs(:constraint_locations).returns(
          'my_location' => {
              'rsc' => 'my_resource',
              'node' => 'my_node',
              'score' => '100',
          }
      )
      provider.exists?
      expect(provider.primitive).to eq('my_resource')
      expect(provider.node).to eq('my_node')
      expect(provider.score).to eq('100')
    end
  end

  context '#destroy' do
    it 'can remove a location' do
      xml = "<rsc_location id='my_location'/>\n"
      provider.expects(:wait_for_constraint_remove).with xml, resource[:name]
      provider.destroy
    end
  end
end
