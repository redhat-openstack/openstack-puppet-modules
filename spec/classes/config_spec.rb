require 'spec_helper'
describe 'cassandra::config' do

  context 'With defaults for all parameters' do
  it {
    should contain_class('cassandra::config')
  }
  end
end
