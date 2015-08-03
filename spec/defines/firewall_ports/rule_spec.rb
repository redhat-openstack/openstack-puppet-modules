require 'spec_helper'
describe 'cassandra::firewall_ports::rule' do
  let(:pre_condition) { [
    'define firewall ($action, $port, $proto, $source) {}',
  ] }

  context 'Test that rules can be set.' do
    let(:title) { 'SSH_0.0.0.0/0' }
    let :params do
      {
        :port   => 22,
      }
    end

    it { should compile }

    it {
      should contain_firewall('22 (SSH) - 0.0.0.0/0').with({
        'port'   => 22,
        'source' => '0.0.0.0/0',
      })
    }
  end
end
