require 'spec_helper'

describe Puppet::Type.type(:pacemaker_order).provider(:xml) do
  let(:resource) do
    Puppet::Type.type(:pacemaker_order).new(
        name: 'my_order',
        first: 'p_1',
        second: 'p_2',
        provider: :xml,
    )
  end

  let(:provider) do
    resource.provider
  end

  before(:each) do
    puppet_debug_override
    provider.stubs(:cluster_debug_report).returns(true)
    provider.stubs(:primitive_exists?).with('p_1').returns(true)
    provider.stubs(:primitive_exists?).with('p_2').returns(true)
  end

  describe('#validation') do
    it 'should fail if there is no "first" primitive in the CIB' do
      provider.stubs(:primitive_exists?).with('p_1').returns(false)
      provider.create
      expect { provider.flush }.to raise_error "Primitive 'p_1' does not exist!"
    end

    it 'should fail if there is no "then" primitive in the CIB' do
      provider.stubs(:primitive_exists?).with('p_2').returns(false)
      provider.create
      expect { provider.flush }.to raise_error "Primitive 'p_2' does not exist!"
    end
  end

  context 'with #score' do
    it 'should update an order' do
      resource[:first] = 'p_1'
      resource[:second] = 'p_2'
      resource[:score] = '100'
      provider.stubs(:constraint_order_exists?).returns(true)
      xml = <<-eos
<rsc_order first='p_1' id='my_order' score='100' then='p_2'/>
      eos
      provider.expects(:wait_for_constraint_update).with xml, resource[:name]
      provider.create
      provider.property_hash[:ensure] = :present
      provider.flush
    end

    it 'should create an order' do
      resource[:first] = 'p_1'
      resource[:second] = 'p_2'
      resource[:score] = '100'
      xml = <<-eos
<rsc_order first='p_1' id='my_order' score='100' then='p_2'/>
      eos
      provider.expects(:wait_for_constraint_create).with xml, resource['name']
      provider.create
      provider.property_hash[:ensure] = :absent
      provider.flush
    end
  end

  context 'with #kind' do
    it 'should update an order' do
      resource[:first] = 'p_1'
      resource[:second] = 'p_2'
      resource[:first_action] = 'promote'
      resource[:second_action] = 'demote'
      resource[:kind] = 'serialize'
      resource[:symmetrical] = false
      resource[:require_all] = false
      provider.stubs(:constraint_order_exists?).returns(true)
      xml = <<-eos
<rsc_order first='p_1' first-action='promote' id='my_order' kind='Serialize' require-all='false' symmetrical='false' then='p_2' then-action='demote'/>
      eos
      provider.expects(:wait_for_constraint_update).with xml, resource[:name]
      provider.create
      provider.property_hash[:ensure] = :present
      provider.flush
    end

    it 'should create an order' do
      resource[:first] = 'p_1'
      resource[:second] = 'p_2'
      resource[:first_action] = 'promote'
      resource[:second_action] = 'demote'
      resource[:kind] = 'serialize'
      resource[:symmetrical] = false
      resource[:require_all] = false
      xml = <<-eos
<rsc_order first='p_1' first-action='promote' id='my_order' kind='Serialize' require-all='false' symmetrical='false' then='p_2' then-action='demote'/>
      eos
      provider.expects(:wait_for_constraint_create).with xml, resource['name']
      provider.create
      provider.property_hash[:ensure] = :absent
      provider.flush
    end
  end

  describe '#destroy' do
    it 'should destroy order with corresponding name' do
      xml = "<rsc_order id='my_order'/>\n"
      provider.expects(:wait_for_constraint_remove).with xml, resource[:name]
      provider.destroy
      provider.flush
    end
  end
end
