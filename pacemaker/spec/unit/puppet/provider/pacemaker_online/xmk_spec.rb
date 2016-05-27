require 'spec_helper'

describe Puppet::Type.type(:pacemaker_online).provider(:xml) do
  let(:resource) do
    Puppet::Type.type(:pacemaker_online).new(
        name: 'online',
        status: :online,
        provider: :xml,
    )
  end

  let(:provider) do
    resource.provider
  end

  before(:each) do
    puppet_debug_override
  end

  it 'can get the status from the library function' do
    provider.stubs(:online?).returns(false)
    expect(provider.status).to eq :offline
    provider.stubs(:online?).returns(true)
    expect(provider.status).to eq :online
  end

  it 'can wait for online status' do
    provider.expects(:wait_for_online).with('pacemaker_online').returns(true)
    provider.status = :online
    provider.expects(:wait_for_online).never
    provider.status = :offline
  end
end
