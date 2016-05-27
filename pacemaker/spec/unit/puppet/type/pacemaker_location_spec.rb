require 'spec_helper'

describe Puppet::Type.type(:pacemaker_location) do
  subject do
    Puppet::Type.type(:pacemaker_location)
  end

  it 'should have a "name" parameter' do
    expect(
        subject.new(
            name: 'mock_resource',
            node: 'node',
            score: '100',
            primitive: 'my_primitive'
        )[:name]
    ).to eq('mock_resource')
  end

  context 'basic structure' do
    it 'should be able to create an instance' do
      expect(
          subject.new(
              name: 'mock_resource',
              node: 'node',
              score: '100',
              primitive: 'my_primitive'
          )
      ).to_not be_nil
    end

    [:name].each do |param|
      it "should have a #{param} parameter" do
        expect(subject.validparameter?(param)).to be_truthy
      end

      it "should have documentation for its #{param} parameter" do
        expect(subject.paramclass(param).doc).to be_a(String)
      end
    end

    [:primitive, :node, :score, :rules].each do |property|
      it "should have a #{property} property" do
        expect(subject.validproperty?(property)).to be_truthy
      end
      it "should have documentation for its #{property} property" do
        expect(subject.propertybyname(property).doc).to be_a(String)
      end
    end
  end

  context 'validation and munging' do
    context 'node score' do
      it 'should allow only correct node score values' do
        expect {
          subject.new(
              name: 'mock_resource',
              primitive: 'my_primitive',
              node: 'node',
              score: 'test'
          )
        }.to raise_error(/Score parameter is invalid/)
        expect(subject.new(
            name: 'mock_resource',
            primitive: 'my_primitive',
            node: 'node',
            score: '100'
        )).to_not be_nil
        expect(subject.new(
            name: 'mock_resource',
            primitive: 'my_primitive',
            node: 'node',
            score: 'inf'
        )).to_not be_nil
      end

      it 'should change inf to INFINITY' do
        expect(
            subject.new(
                name: 'mock_resource',
                primitive: 'my_primitive',
                node: 'node',
                score: 'inf'
            )[:score]
        ).to eq 'INFINITY'
        expect(
            subject.new(
                name: 'mock_resource',
                primitive: 'my_primitive',
                node: 'node',
                score: '-inf'
            )[:score]
        ).to eq '-INFINITY'
      end
    end

    context 'rules' do
      it 'should stringify keys and values' do
        expect(
            subject.new(
                name: 'mock_resource',
                primitive: 'my_primitive',
                rules: {
                    'id' => 'test',
                    'boolean-op' => :or,
                    :a => 1,
                    2 => :c
                }
            )[:rules].first
        ).to eq('boolean-op' => 'or',
                'id' => 'test',
                '2' => 'c',
                'a' => '1')
      end
      it 'should generate missing rule id' do
        expect(
            subject.new(
                name: 'mock_resource',
                primitive: 'my_primitive',
                rules: {
                    'a' => '1',
                    'boolean-op' => 'or'
                }
            )[:rules].first
        ).to eq('boolean-op' => 'or',
                'id' => 'mock_resource-rule-0',
                'a' => '1')
      end
      it 'should add missing boolean-op' do
        expect(
            subject.new(
                name: 'mock_resource',
                primitive: 'my_primitive',
                rules: {
                    'id' => 'test'
                }
            )[:rules].first
        ).to eq('boolean-op' => 'or',
                'id' => 'test')
      end
      it 'should change rule score from inf to INFINITY' do
        expect(
            subject.new(
                name: 'mock_resource',
                primitive: 'my_primitive',
                rules: {
                    'id' => 'test',
                    'boolean-op' => 'and',
                    'score' => 'inf'
                }
            )[:rules].first
        ).to eq('boolean-op' => 'and',
                'id' => 'test',
                'score' => 'INFINITY')
      end
      it 'should generate missing expression id' do
        expect(
            subject.new(
                name: 'mock_resource',
                primitive: 'my_primitive',
                rules: {
                    score: 'inf',
                    id: 'test',
                    expressions: [
                        {
                            attribute: 'pingd1',
                            operation: 'defined',
                            id: 'first_expression',
                        },
                        {
                            attribute: 'pingd2',
                            operation: 'defined',
                        }
                    ]
                }
            )[:rules].first
        ).to eq('score' => 'INFINITY', 'id' => 'test', 'boolean-op' => 'or',
                'expressions' => [
                    {
                        'operation' => 'defined',
                        'attribute' => 'pingd1',
                        'id' => 'first_expression',
                    },
                    {
                        'operation' => 'defined',
                        'attribute' => 'pingd2',
                        'id' => 'mock_resource-rule-0-expression-1',
                    }
                ])
      end
    end

    context '#autorequire' do
      it 'should autorequire the corresponding resources' do
        pacemaker_resource = Puppet::Type.type(:pacemaker_resource).new(
            name: 'my_primitive',
            ensure: :present,
        )
        catalog = Puppet::Resource::Catalog.new
        catalog.add_resource pacemaker_resource
        pacemaker_location = Puppet::Type.type(:pacemaker_location).new(
            name: 'mock_resource',
            primitive: 'my_primitive',
            node: 'node',
            score: 'inf'
        )
        pacemaker_location.stubs(:autorequire_enabled?).returns(true)
        catalog.add_resource pacemaker_location
        required_resources = pacemaker_location.autorequire
        expect(required_resources.size).to eq 1
        expect(required_resources.first.target).to eq pacemaker_location
        expect([pacemaker_resource]).to include required_resources.first.source
      end
    end
  end
end
