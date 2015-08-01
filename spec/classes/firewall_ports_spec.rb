require 'spec_helper'
describe 'cassandra::firewall_ports' do
  let(:pre_condition) { [
    'define firewall ($action, $port, $proto, $source) {}',
    'function prefix ($a, $p) { }'
  ] }
end
