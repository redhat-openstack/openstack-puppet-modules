require 'spec_helper'
describe 'cassandra::opscenter' do
  let(:pre_condition) { [
    'define ini_setting ($ensure = nil,
      $path,
      $section,
      $key_val_separator = nil,
      $setting,
      $value = nil) {}'
  ] }

  context 'Test params for cassandra::opscenter defaults.' do
    it {
      should contain_class('cassandra::opscenter').with({
        'authentication_enabled' => 'False',
        'ensure'                 => 'present',
        'config_file'            => '/etc/opscenter/opscenterd.conf',
        'package_name'           => 'opscenter',
        'service_enable'         => 'true',
        'service_ensure'         => 'running',
        'service_name'           => 'opscenterd',
        'webserver_interface'    => '0.0.0.0',
        'webserver_port'         => 8888,
      })
    }
  end

  context 'Test params for cassandra::opscenter special cases.' do
    let :params do
      {
        :authentication_method            => 42,
        :failover_configuration_directory => '/path/to',
      }
    end

    it {
      should contain_class('cassandra::opscenter').with({
        'authentication_method'            => 42,
        'failover_configuration_directory' => '/path/to',
      })
    }
  end

  context 'Test for cassandra::opscenter package.' do
    it {
      should contain_package('opscenter')
    }
  end

  context 'Test for cassandra::opscenter service.' do
    it {
      should contain_service('opscenterd')
    }
  end
end
