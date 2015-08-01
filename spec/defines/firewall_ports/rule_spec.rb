require 'spec_helper'
describe 'cassandra::firewall_ports::rule' do
  let(:pre_condition) { [
    'define firewall ($action, $port, $proto, $source) {}'
  ] }

  context 'Test that rules can be set.' do
    let(:title) { '0.0.0.0/0' }
    let :params do
      {
        :action => 'accept',
        :port   => 22,
      }
    end

    it { should compile }

    it {
      should contain_firewall('22 - 0.0.0.0/0').with({
        'action' => 'accept',
        'port'   => 22,
        'source' => '0.0.0.0/0',
      })
    }
  end
end
