require 'spec_helper'

describe Puppet::Type.type(:pacemaker_pcsd_auth) do
  subject do
    Puppet::Type.type(:pacemaker_pcsd_auth)
  end

  let(:instance) do
    subject.new(
        name: 'auth',
        nodes: %w(node1 node2),
        password: 'test',
        provider: :pcs,
    )
  end

  context 'basic' do
    it 'should be able to create an instance' do
      expect(instance).to_not be_nil
    end

    [:name, :nodes, :username, :password, :force, :local, :whole].each do |param|
      it "should have a #{param} parameter" do
        expect(subject.validparameter?(param)).to be_truthy
      end

      it "should have documentation for its #{param} parameter" do
        expect(subject.paramclass(param).doc).to be_a String
      end
    end

    [:success].each do |property|
      it "should have a #{property} property" do
        expect(subject.validproperty?(property)).to be_truthy
      end
      it "should have documentation for its #{property} property" do
        expect(subject.propertybyname(property).doc).to be_a String
      end
    end
  end

  context 'refresh' do
    it 'should support the refresh event' do
      expect(instance).to respond_to :refresh
    end

    it 'should re-authenticate the nodes' do
      instance.provider.expects(:success).returns(false)
      instance.provider.expects(:success=).with(true)
      instance.refresh
      expect(instance[:force]).to eq true
    end
  end

end
