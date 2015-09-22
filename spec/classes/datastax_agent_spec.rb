require 'spec_helper'
describe 'cassandra::datastax_agent' do
  let(:pre_condition) { [
    'define ini_setting ($ensure, $path, $section, $key_val_separator, $setting, $value) {}'
  ] }

  context 'Test for cassandra::datastax_agent.' do
    it { should have_resource_count(3) }
    it {
      should contain_class('cassandra::datastax_agent').only_with(
        'defaults_file'   => '/etc/default/datastax-agent',
        #'java_home'       => nil,
        'package_ensure'  => 'present',
        'package_name'    => 'datastax-agent',
        'service_ensure'  => 'running',
        'service_enable'  => true,
        'service_name'    => 'datastax-agent',
        'stomp_interface' => nil,
      )
    }
    it {
      should contain_package('datastax-agent')
    }
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

    it { should contain_ini_setting('stomp_interface').with_ensure('present') }
    it {
      should contain_ini_setting('stomp_interface').with_value('192.168.0.1')
    }
  end

  context 'Test that stomp_interface can be ignored.' do
    it {
      should contain_ini_setting('stomp_interface').with_ensure('absent')
    }
  end

  context 'Test that the JAVA_HOME can be set.' do
    let :params do
      {
        :java_home => '/usr/lib/jvm/java-8-oracle'
      }
    end

    it {
      should contain_ini_setting('java_home').with(
        'ensure' => 'present',
        'path'   => '/etc/default/datastax-agent',
        'value'  => '/usr/lib/jvm/java-8-oracle'
      )
    }
  end
end
