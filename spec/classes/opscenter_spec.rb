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

  context 'Test for cassandra::opscenter with defaults.' do
    it {
      should contain_class('cassandra::opscenter').only_with({
        'authentication_enabled' => 'False',
        'ensure'                 => 'present',
        'config_file'            => '/etc/opscenter/opscenterd.conf',
        'interface'              => '0.0.0.0',
        'package_name'           => 'opscenter',
        'port'                   => 8888,
        'service_enable'         => 'true',
        'service_ensure'         => 'running',
        'ssl_keyfile'            => nil,
        'service_name'           => 'opscenterd'
      })
    }
  end

  context 'Test for cassandra::opscenter package.' do
    it {
      should contain_package('opscenter')
    }
  end

  context 'Test authentication enabled.' do
    it {
      should contain_cassandra__opscenter__setting('authentication enabled').only_with({
        'name'         => 'authentication enabled',
        'service_name' => 'opscenterd',
        'path'         => '/etc/opscenter/opscenterd.conf',
        'section'      => 'authentication',
        'setting'      => 'enabled',
        'value'        => 'False'
      })
    }
  end

  context 'webserver port.' do
    it {
      should contain_cassandra__opscenter__setting('webserver port').only_with({
        'name'         => 'webserver port',
        'service_name' => 'opscenterd',
        'path'         => '/etc/opscenter/opscenterd.conf',
        'section'      => 'webserver',
        'setting'      => 'port',
        'value'        => 8888
      })
    }
  end

  context 'webserver interface.' do
    it {
      should contain_cassandra__opscenter__setting('webserver interface').only_with({
        'name'         => 'webserver interface',
        'service_name' => 'opscenterd',
        'path'         => '/etc/opscenter/opscenterd.conf',
        'section'      => 'webserver',
        'setting'      => 'interface',
        'value'        => '0.0.0.0'
      })
    }
  end

  context 'webserver ssl_keyfile.' do
    it { should contain_cassandra__opscenter__setting(
           'webserver ssl_keyfile').only_with({
        'name'         => 'webserver ssl_keyfile',
        'service_name' => 'opscenterd',
        'path'         => '/etc/opscenter/opscenterd.conf',
        'section'      => 'webserver',
        'setting'      => 'ssl_keyfile'
      })
    }
  end

  context 'webserver ssl_port.' do
    it { should contain_cassandra__opscenter__setting(
           'webserver ssl_port').only_with({
        'name'         => 'webserver ssl_port',
        'service_name' => 'opscenterd',
        'path'         => '/etc/opscenter/opscenterd.conf',
        'section'      => 'webserver',
        'setting'      => 'ssl_port'
      })
    }
  end

  context 'webserver ssl_certfile.' do
    it { should contain_cassandra__opscenter__setting(
           'webserver ssl_certfile').only_with({
        'name'         => 'webserver ssl_certfile',
        'service_name' => 'opscenterd',
        'path'         => '/etc/opscenter/opscenterd.conf',
        'section'      => 'webserver',
        'setting'      => 'ssl_certfile'
      })
    }
  end

  context 'Test for cassandra::opscenter service.' do
    it {
      should contain_service('opscenterd')
    }
  end
end
