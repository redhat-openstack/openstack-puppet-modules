require 'spec_helper'

describe 'manila::params' do

  let :facts do
    {:osfamily => 'Debian'}
  end
  it 'should compile' do
    subject
  end

end
