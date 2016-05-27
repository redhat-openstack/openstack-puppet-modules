require 'spec_helper'

describe Puppet::Type.type(:pacemaker_operation_default) do
  subject do
    Puppet::Type.type(:pacemaker_operation_default)
  end

  it "should have a 'name' parameter" do
    expect(
        subject.new(
            name: 'mock_operation',
            value: 'mock_value'
        )[:name]
    ).to eq 'mock_operation'
  end

  describe 'basic structure' do
    it 'should be able to create an instance' do
      expect(
          subject.new(
              name: 'mock_operation',
              value: 'mock_value'
          )
      ).to_not be_nil
    end

    [:name].each do |param|
      it "should have a #{param} parameter" do
        expect(subject.validparameter?(param)).to be_truthy
      end

      it "should have documentation for its #{param} parameter" do
        expect(subject.paramclass(param).doc).to be_a String
      end
    end

    it 'should have a value property' do
      expect(subject.validproperty?(:value)).to be_truthy
    end

    it 'should have documentation for its value property' do
      expect(subject.propertybyname(:value).doc).to be_a String
    end
  end
end
