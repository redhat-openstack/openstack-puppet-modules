require 'spec_helper'
describe 'cassandra::firewall_ports' do
  let(:pre_condition) { [
    'define firewall ($action, $port, $proto, $source) {}',
  ] }

  let!(:stdlib_stubs) { MockFunction.new('prefix') { |f|
      f.stubbed.with(['0.0.0.0/0'], 'Cassandra_').returns('Cassandra_0.0.0.0/0')
      f.stubbed.with(['0.0.0.0/0'], 'SSH_').returns('SSH_0.0.0.0/0')
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

    it {
      should contain_cassandra__firewall_ports__rule('SSH_0.0.0.0/0').with({
        'port' => 22
      })
    }
  end
end
