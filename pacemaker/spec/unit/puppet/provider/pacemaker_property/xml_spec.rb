require 'spec_helper'

describe Puppet::Type.type(:pacemaker_property).provider(:xml) do
  let(:resource) do
    Puppet::Type.type(:pacemaker_property).new(
        name: 'my_property',
        value: 'my_value',
        provider: :xml,
    )
  end

  let(:provider) do
    resource.provider
  end

  before(:each) do
    puppet_debug_override
    provider.stubs(:wait_for_online)
  end

  describe '#exists?' do
    it 'should determine if the property is defined' do
      provider.expects(:cluster_property_defined?).with('my_property')
      provider.exists?
    end
  end

  describe '#create' do
    it 'should create property with corresponding value' do
      provider.expects(:cluster_property_set).with('my_property', 'my_value')
      provider.create
    end
  end

  describe '#update' do
    it 'should update property with corresponding value' do
      provider.expects(:cluster_property_set).with('my_property', 'my_value')
      provider.value = 'my_value'
    end
  end

  describe '#get' do
    it 'should get a property' do
      provider.expects(:cluster_property_value).with('my_property')
      provider.value
    end
  end

  describe '#destroy' do
    it 'should destroy property with corresponding name' do
      provider.expects(:cluster_property_delete).with('my_property')
      provider.destroy
    end
  end
end
