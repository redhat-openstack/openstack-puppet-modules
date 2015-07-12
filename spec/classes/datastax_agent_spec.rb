require 'spec_helper'
describe 'cassandra::datastax_agent' do

  context 'Test for cassandra::datastax_agent.' do
    it {
      should contain_class('cassandra::datastax_agent').with_package_ensure('present')
      should contain_class('cassandra::datastax_agent').with_package_name('datastax-agent')
      should contain_class('cassandra::datastax_agent').with_service_enable('true')
      should contain_class('cassandra::datastax_agent').with_service_ensure('running')
      should contain_class('cassandra::datastax_agent').with_service_name('datastax-agent')
      should contain_class('cassandra::datastax_agent').with_stomp_interface()
    }
  end

  context 'Test for cassandra::datastax_agent package.' do
    it {
      should contain_package('datastax-agent')
    }
  end

  context 'Test for cassandra::datastax_agent service.' do
    it {
      should contain_service('datastax-agent')
    }
  end

  context 'Test that stomp_interface can be set.' do
    let :params do
      {
        :stomp_interface => '192.168.0.1'
      }
    end

    it {
      should contain_ini_setting('stomp_interface').with_ensure('present')
      should contain_ini_setting('stomp_interface').with_value('192.168.0.1')
    }
  end

  context 'Test that stomp_interface can be ignored.' do
    it {
      should contain_ini_setting('stomp_interface').with_ensure('absent')
    }
  end
end
