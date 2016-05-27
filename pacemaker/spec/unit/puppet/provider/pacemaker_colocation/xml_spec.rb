require 'spec_helper'

describe Puppet::Type.type(:pacemaker_colocation).provider(:xml) do
  let(:resource) do
    Puppet::Type.type(:pacemaker_colocation).new(
        name: 'my_colocation',
        first: 'foo',
        second: 'bar',
        provider: :xml,
    )
  end

  let(:provider) do
    resource.provider
  end

  before(:each) do
    puppet_debug_override
    provider.stubs(:cluster_debug_report).returns(true)
    provider.stubs(:constraint_colocation_exists?).returns(false)
    provider.stubs(:primitive_exists?).with('foo').returns(true)
    provider.stubs(:primitive_exists?).with('bar').returns(true)
  end

  describe('#validation') do
    it 'should fail if there is no first primitive in the CIB' do
      provider.stubs(:primitive_exists?).with('foo').returns(false)
      provider.create
      expect { provider.flush }.to raise_error "Primitive 'foo' does not exist!"
    end

    it 'should fail if there is no second primitive in the CIB' do
      provider.stubs(:primitive_exists?).with('bar').returns(false)
      provider.create
      expect { provider.flush }.to raise_error "Primitive 'bar' does not exist!"
    end

    it 'should fail if there is no "score" set' do
      resource.delete :score
      provider.create
      expect { provider.flush }.to raise_error 'Data does not contain all the required fields!'
    end
  end

  describe '#update' do
    it 'should update a colocation' do
      resource[:score] = '200'
      provider.stubs(:constraint_colocation_exists?).returns(true)
      xml = <<-eos
<rsc_colocation id='my_colocation' rsc='bar' score='200' with-rsc='foo'/>
      eos
      provider.expects(:wait_for_constraint_update).with xml, resource[:name]
      provider.create
      provider.property_hash[:ensure] = :present
      provider.flush
    end
  end

  describe '#create' do
    it 'should create a colocation with corresponding members' do
      resource[:score] = 'inf'

      xml = <<-eos
<rsc_colocation id='my_colocation' rsc='bar' score='INFINITY' with-rsc='foo'/>
      eos
      provider.expects(:wait_for_constraint_create).with xml, resource[:name]
      provider.create
      provider.property_hash[:ensure] = :absent
      provider.flush
    end
  end

  describe '#destroy' do
    it 'should destroy colocation with corresponding name' do
      xml = "<rsc_colocation id='my_colocation'/>\n"
      provider.expects(:wait_for_constraint_remove).with xml, resource[:name]
      provider.destroy
      provider.flush
    end
  end
end
