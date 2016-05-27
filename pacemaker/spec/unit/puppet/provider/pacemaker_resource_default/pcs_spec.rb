require 'spec_helper'

describe Puppet::Type.type(:pacemaker_resource_default).provider(:pcs) do
  let(:resource) do
    Puppet::Type.type(:pacemaker_resource_default).new(
        name: 'my_default',
        value: 'my_value',
        provider: :pcs,
    )
  end

  let(:provider) do
    resource.provider
  end

  before(:each) do
    puppet_debug_override
  end

  describe '#exists?' do
    it 'should determine if the rsc_default is defined' do
      provider.expects(:pcs_resource_default_defined?).with('my_default')
      provider.exists?
    end
  end

  describe '#create' do
    it 'should create resource default with corresponding value' do
      provider.expects(:pcs_resource_default_set).with('my_default', 'my_value')
      provider.create
    end
  end

  describe '#update' do
    it 'should update resource default with corresponding value' do
      provider.expects(:pcs_resource_default_set).with('my_default', 'my_value')
      provider.value = 'my_value'
    end
  end

  describe '#get' do
    it 'should get a property' do
      provider.expects(:pcs_resource_default_value).with('my_default')
      provider.value
    end
  end

  describe '#destroy' do
    it 'should destroy resource default with corresponding name' do
      provider.expects(:pcs_resource_default_delete).with('my_default')
      provider.destroy
    end
  end
end
