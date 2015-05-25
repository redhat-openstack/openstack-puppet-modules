require 'spec_helper'
describe 'cassandra' do

  context 'with defaults for all parameters' do
    it { should contain_class('cassandra') }
  end
end
