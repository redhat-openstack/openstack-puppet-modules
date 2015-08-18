require 'spec_helper'
describe 'cassandra::firewall_ports::rule' do
  let(:pre_condition) { [
    'define firewall ($action, $port, $proto, $source) {}',
  ] }

  let!(:stdlib_stubs) {
    MockFunction.new('prefix') { |f|
      f.stubbed.with(['0.0.0.0/0'],
        '200_Public_').returns('200_Public_0.0.0.0/0')
      f.stubbed.with(['0.0.0.0/0'],
        '210_InterNode_').returns('210_InterNode__0.0.0.0/0')
      f.stubbed.with(['0.0.0.0/0'],
        '220_Client_').returns('220_Client__0.0.0.0/0')
    }
    MockFunction.new('concat') { |f|
      f.stubbed().returns([8888, 22])
    }
    MockFunction.new('size') { |f|
      f.stubbed().returns(42)
    }
  }

  context 'Test that rules can be set.' do
    let(:title) { '200_Public_0.0.0.0/0' }
    let :params do
      {
        :ports => [8888, 22],
      }
    end

    it { should compile }
  end
end
