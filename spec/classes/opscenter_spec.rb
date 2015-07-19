require 'spec_helper'
describe 'cassandra::opscenter' do
  let(:pre_condition) { [
    'define ini_setting ($ensure,
      $path,
      $section,
      $key_val_separator,
      $setting,
      $value) {}'
  ] }

  context 'Test for cassandra::opscenter.' do
    it {
      should contain_class('cassandra::opscenter').with({
        'authentication_enabled' => 'False',
        'ensure'                 => 'present',
        'config_file'            => '/etc/opscenter/opscenterd.conf',
        'interface'              => '0.0.0.0',
        'package_name'           => 'opscenter',
        'port'                   => 8888,
        'service_enable'         => 'true',
        'service_ensure'         => 'running',
        'service_name'           => 'opscenterd',
        'ssl_keyfile'            => 'undef',
        'ssl_certfile'           => 'undef',
        'ssl_port'               => 'undef',
      })
    }
  end

  context 'Test for cassandra::opscenter package.' do
    it {
      should contain_package('opscenter')
    }
  end

  context 'Test authentication setting.' do
    it {
      should contain_ini_setting('authentication_enabled').with({
        'ensure'  => 'present',
        'path'    => '/etc/opscenter/opscenterd.conf',
        'section' => 'authentication',
        'setting' => 'enabled',
        'value'   => 'False',
      })
    }
  end

  context 'Test authentication setting.' do
    it {
      should contain_ini_setting('authentication_enabled').with({
        'ensure'  => 'present',
        'path'    => '/etc/opscenter/opscenterd.conf',
        'section' => 'authentication',
        'setting' => 'enabled',
        'value'   => 'False',
      })
    }
  end

  context 'Test for cassandra::opscenter service.' do
    it {
      should contain_service('opscenterd')
    }
  end
end
