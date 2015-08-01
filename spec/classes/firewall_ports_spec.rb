require 'spec_helper'
describe 'cassandra::firewall_ports' do
  let(:pre_condition) { [
    'define firewall ($action, $port, $proto, $source) {}',
    'function prefix ($a, $p) { }'
  ] }

  context 'Ensure public_subnets can be bypassed.' do
    let :params do
      {
        :public_subnets => nil
      }
    end
  end
end
