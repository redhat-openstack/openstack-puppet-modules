require 'spec_helper'

describe 'kibana3::params', :type => :class do
  context 'with defaults' do
    it { should compile }
    it { should have_resource_count(0) }
  end
end
