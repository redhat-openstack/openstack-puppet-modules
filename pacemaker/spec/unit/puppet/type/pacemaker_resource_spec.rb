require 'spec_helper'
require 'set'

describe Puppet::Type.type(:pacemaker_resource) do
  subject do
    Puppet::Type.type(:pacemaker_resource)
  end

  let(:instance) do
    subject.new(
        name: 'mock_resource',
    )
  end

  before(:each) do
    puppet_debug_override
  end

  it "should have a 'name' parameter" do
    expect(instance[:name]).to eq('mock_resource')
  end

  describe 'basic structure' do
    it 'should be able to create an instance' do
      expect(instance).to_not be_nil
    end

    [:name].each do |param|
      it "should have a #{param} parameter" do
        expect(subject.validparameter?(param)).to be_truthy
      end

      it "should have documentation for its #{param} parameter" do
        expect(subject.paramclass(param).doc).to be_instance_of(String)
      end
    end

    [:primitive_class, :primitive_type, :primitive_provider,
     :parameters, :operations, :complex_metadata, :complex_type].each do |property|
      it "should have a #{property} property" do
        expect(subject.validproperty?(property)).to be_truthy
      end

      it "should have documentation for its #{property} property" do
        expect(subject.propertybyname(property).doc).to be_instance_of(String)
      end
    end
  end

  describe 'when validating attributes' do
    [:parameters, :operations, :metadata, :complex_metadata].each do |attribute|
      it "should validate that the #{attribute} attribute defaults to nil" do
        expect(instance[:parameters]).to be_nil
      end

      it "should validate that the #{attribute} attribute must be a hash" do
        expect {
          subject.new(
              name: 'mock_resource',
              parameters: 'fail'
          )
        }.to raise_error(Puppet::Error, /hash/)
      end
    end

    it 'should validate that the complex_type type attribute cannot be other values' do
      ['fail', 42].each do |value|
        expect {
          instance[:complex_type] = value
        }.to raise_error(Puppet::Error, /(master|clone|\'\')/)
      end
    end
  end

  describe 'munging of input data' do
    [:parameters, :metadata, :complex_metadata].each do |hash|
      it "should convert hash keys and values to strings on #{hash}" do
        instance[hash] = {:a => 1, 'b' => true, 'c' => {:a => true, 'b' => :s, 4 => 'd'}}
        expected_data = {'a' => '1', 'b' => 'true', 'c' => {'a' => 'true', 'b' => 's', '4' => 'd'}}
        expect(instance[hash]).to eq expected_data
      end
    end

    context 'on operations' do
      it 'should change operations format if provided as hash' do
        data_from = {'start' => {'timeout' => '20', 'interval' => '0'}, 'monitor' => {'interval' => '10'}}
        data_to = [{'interval' => '10', 'name' => 'monitor'}, {'timeout' => '20', 'name' => 'start', 'interval' => '0'}]
        instance[:operations] = data_from
        expect(instance[:operations]).to eq [Set.new(data_to)]
      end

      it 'should support several monitor operations' do
        data_from = [{'interval' => '10', 'name' => 'monitor'}, {'interval' => '20', 'name' => 'monitor'}]
        data_to = [{'interval' => '10', 'name' => 'monitor'}, {'interval' => '20', 'name' => 'monitor'}]
        instance[:operations] = data_from
        expect(instance[:operations]).to eq [Set.new(data_to)]
      end

      it 'should reset non-monitor operation interval to 0' do
        data_from = {'start' => {'timeout' => '20', 'interval' => '10'}, 'stop' => {'interval' => '20', 'timeout' => '20'}}
        data_to = [{'timeout' => '20', 'name' => 'start', 'interval' => '0'}, {'interval' => '0', 'name' => 'stop', 'timeout' => '20', }]
        instance[:operations] = data_from
        expect(instance[:operations]).to eq [Set.new(data_to)]
      end

      it 'should add missing interval values' do
        data_from = [{'interval' => '10', 'name' => 'monitor'}, {'timeout' => '20', 'name' => 'start'}]
        data_to = [{'interval' => '10', 'name' => 'monitor'}, {'timeout' => '20', 'name' => 'start', 'interval' => '0'}]
        instance[:operations] = data_from
        expect(instance[:operations]).to eq [Set.new(data_to)]
      end

      it 'should capitalize role value' do
        data_from = [{'interval' => '10', 'name' => 'monitor', 'role' => 'master'}]
        data_to = [{'interval' => '10', 'name' => 'monitor', 'role' => 'Master'}]
        instance[:operations] = data_from
        expect(instance[:operations]).to eq [Set.new(data_to)]
      end

      it 'should stringify operations structure' do
        data_from = {'interval' => 10, :name => 'monitor'}
        data_to = [{'interval' => '10', 'name' => 'monitor'}]
        instance[:operations] = data_from
        expect(instance[:operations]).to eq [Set.new(data_to)]
      end
    end

    describe 'special insync? conditions' do
      before :each do
        instance[:name] = 'my_resource'
        instance[:complex_metadata] = {
            'a' => 1,
            'target-role' => 'Stopped',
        }
        instance[:metadata] = {
            'a' => 2,
            'is-managed' => 'true',
        }
        instance[:complex_type] = 'master'
      end

      it 'should ignore status metadata from complex_metadata hash comparison' do
        complex_metadata = instance.property(:complex_metadata)
        expect(complex_metadata.insync?('a' => '1', 'target-role' => 'Started')).to be_truthy
      end

      it 'should ignore status metadata from metadata hash comparison' do
        metadata = instance.property(:metadata)
        expect(metadata.insync?('a' => '2', 'is-managed' => 'false')).to be_truthy
      end

      it 'should compare non-status complex_metadata' do
        complex_metadata = instance.property(:complex_metadata)
        expect(complex_metadata.insync?('a' => 2)).to be_falsey
      end

      it 'should compare non-status metadata' do
        metadata = instance.property(:metadata)
        expect(metadata.insync?('a' => 1)).to be_falsey
      end
    end
  end
end
