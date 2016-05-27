require 'spec_helper'

describe Puppet::Type.type(:pacemaker_online) do
  subject do
    Puppet::Type.type(:pacemaker_online)
  end

  it "should have a 'name' parameter" do
    expect(
        subject.new(
            name: 'mock_name',
            status: :online,
        )[:name]
    ).to eq 'mock_name'
  end

  it "should have a 'status' parameter" do
    expect(
        subject.new(
            name: 'mock_name',
            status: :online,
        )[:status]
    ).to eq :online
  end

  it 'should not allow unsupported statuses' do
    expect {
      subject.new(
          name: 'mock_name',
          status: :pending,
      )
    }.to raise_error(/Invalid value :pending/)
  end
end
