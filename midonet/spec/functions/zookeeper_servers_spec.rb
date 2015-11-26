require 'spec_helper'

input = [{'id'  => '1', 'host' => 'host1'},
         {'id'  => '2', 'host' => 'host2'}]
output = ['host1', 'host2']

input2 = {'id' => '1', 'host' => 'host1'}
output2 = ['host1']

describe 'zookeeper_servers' do
  it { is_expected.to run.with_params(input).and_return(output) }
  it { is_expected.to run.with_params(input2).and_return(output2) }
end
