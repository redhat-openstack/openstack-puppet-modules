require 'spec_helper'

describe 'tomcat::instance::package', :type => :define do
  let :pre_condition do
    'class { "tomcat": }'
  end
  let :title do
    'tomcat'
  end
  context 'private class fails' do
    let :facts do
      {
        :osfamily           => 'Debian',
        :caller_module_name => 'Test'
      }
    end
    it do
      expect {
        catalogue
      }.to raise_error(Puppet::Error, /Use of private class/)
    end
  end
end
