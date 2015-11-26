require 'spec_helper'

describe 'tomcat::instance::source', :type => :define do
  let :pre_condition do
    'class { "tomcat": }'
  end
  let :title do
    'default'
  end
  context 'private class fails' do
    let :facts do
      {
        :osfamily           => 'Debian',
        :caller_module_name => 'Test'
      }
    end
    let :params do
      {
        :catalina_home => '/opt/apache-tomcat',
        :catalina_base => '/opt/apache-tomcat',
        :source_url    => 'http://mirror.nexcess.net/apache/tomcat/tomcat-8/v8.0.8/bin/apache-tomcat-8.0.8.tar.gz'
      }
    end
    it do
      expect {
        catalogue
      }.to raise_error(Puppet::Error, /Use of private class/)
    end
  end
end
