require 'spec_helper'

describe 'interface2factname' do

  describe 'should return correct results' do

    it 'should run with eth0' do
      should run.with_params('eth0').and_return('ipaddress_eth0')
    end

    it 'should run with bond0:0' do
      should run.with_params('bond0:0').and_return('ipaddress_bond0_0')
    end

    it 'should run with bond0:1' do
      should run.with_params('bond0:1').and_return('ipaddress_bond0_1')
    end
  end
end
