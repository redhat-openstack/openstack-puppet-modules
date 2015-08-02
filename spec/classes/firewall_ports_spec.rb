require 'spec_helper'
describe 'cassandra::firewall_ports' do
  let(:pre_condition) { [
    'define firewall ($action, $port, $proto, $source) {}',
  ] }

  let!(:does_something) { MockFunction.new('prefix') { |f|
      f.stubs(:call).returns('I can do the thing')
    }
  }

  context 'Run with defaults.' do
    it { should compile }

    it {
      should contain_class('cassandra::firewall_ports').with({
        'client_subnets'     => ['0.0.0.0/0'],
        'inter_node_subnets' => ['0.0.0.0/0'],
        'public_subnets'     => ['0.0.0.0/0'],
        'ssh_port'           => 22,
        'opscenter_subnets'  => ['0.0.0.0/0']
      })
    }
  end

  context 'Ensure public_subnets can be bypassed.' do
    let :params do
      {
        :public_subnets => nil
      }
    end
  end
end
