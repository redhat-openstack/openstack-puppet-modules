require 'spec_helper'
describe 'cassandra::firewall_ports' do
  let(:pre_condition) { [
    'define firewall ($action, $port, $proto, $source) {}'
  ] }

  context 'Test for cassandra::firewall_ports.' do
    it {
      should contain_class('cassandra::firewall_ports').with_ssh_port(22)
    }
  end
end
