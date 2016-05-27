require 'spec_helper'

describe Puppet::Type.type(:pacemaker_order) do
  subject do
    Puppet::Type.type(:pacemaker_order)
  end

  it "should have a 'name' parameter" do
    expect(subject.new(
        name: 'mock_resource',
        first: 'foo',
        second: 'bar'
    )[:name]).to eq 'mock_resource'
  end

  describe 'basic structure' do
    it 'should be able to create an instance' do
      expect(subject.new(
          name: 'mock_resource',
          first: 'foo',
          second: 'bar'
      )).to_not be_nil
    end

    [:name, :debug].each do |param|
      it "should have a #{param} parameter" do
        expect(subject.validparameter?(param)).to be_truthy
      end

      it "should have documentation for its #{param} parameter" do
        expect(subject.paramclass(param).doc).to be_a String
      end
    end

    [:first, :second, :first_action, :second_action, :score, :kind, :symmetrical, :require_all].each do |property|
      it "should have a #{property} property" do
        expect(subject.validproperty?(property)).to be_truthy
      end

      it "should have documentation for its #{property} property" do
        expect(subject.propertybyname(property).doc).to be_a String
      end
    end

    it 'should validate the score values' do
      ['fadsfasdf', '10a', nil].each do |value|
        expect { subject.new(
            name: 'mock_colocation',
            first: 'a',
            second: 'b',
            score: value
        )
        }.to raise_error(/score/i)
      end
    end

    it 'should change inf to INFINITY in score' do
      expect(subject.new(
          name: 'mock_colocation',
          first: 'a',
          second: 'b',
          score: 'inf'
      )[:score]).to eq 'INFINITY'
    end

  end

  describe 'when autorequiring resources' do
    before :each do
      @pacemaker_resource_1 = Puppet::Type.type(:pacemaker_resource).new(
          name: 'foo',
          ensure: :present,
      )
      @pacemaker_resource_2 = Puppet::Type.type(:pacemaker_resource).new(
          name: 'bar',
          ensure: :present,
      )
      @catalog = Puppet::Resource::Catalog.new
      @catalog.add_resource @pacemaker_resource_1, @pacemaker_resource_2
    end

    it 'should autorequire the corresponding resources' do
      @resource = described_class.new(
          name: 'dummy',
          first: 'foo',
          second: 'bar',
      )
      @resource.stubs(:autorequire_enabled?).returns(true)
      @catalog.add_resource @resource
      required_resources = @resource.autorequire
      expect(required_resources.size).to eq 2
      required_resources.each do |e|
        expect(e.target).to eq @resource
        expect([@pacemaker_resource_1, @pacemaker_resource_2]).to include e.source
      end
    end
  end

end
