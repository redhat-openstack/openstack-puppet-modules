require 'spec_helper'

require_relative '../../../../lib/puppet/provider/pacemaker_noop'

describe Puppet::Provider::PacemakerNoop do
  let(:resource) do
    Puppet::Type.type(:notify).new(
        name: 'test',
        message: 'test',
    )
  end

  before(:each) do
    subject.stubs(:resource).returns resource
  end

  it 'should exist' do
    is_expected.not_to be_nil
  end

  %w(exists? create destroy flush).each do |method|
    it { is_expected.to respond_to method }
  end

  it 'can create stub property methods' do
    subject.make_property_methods
    expect(subject.message).to eq 'test'
    subject.message = '123'
    expect(subject.message).to eq '123'
  end
end
