require 'spec_helper'

describe 'manila::params' do

  let :facts do
    @default_facts.merge({:osfamily => 'Debian'})
  end
  it 'should compile' do
    subject
  end

end
