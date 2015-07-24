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
      should contain_class('cassandra::opscenter').with({
        'authentication_enabled'            => 'False',
        'ensure'                            => 'present',
        'config_file'                       => '/etc/opscenter/opscenterd.conf',
        'package_name'                      => 'opscenter',
        'service_enable'                    => 'true',
        'service_ensure'                    => 'running',
        'service_name'                      => 'opscenterd',
        'webserver_interface'               => '0.0.0.0',
        'webserver_ssl_keyfile'             => nil,
        'webserver_port'                    => 8888,
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

  context 'Test webserver interface.' do
    it {
      should contain_cassandra__opscenter__setting('webserver interface').with({
        'path'         => '/etc/opscenter/opscenterd.conf',
        'section'      => 'webserver',
        'setting'      => 'interface',
        'value'        => '0.0.0.0'
      })
    }
  end

  context 'Test webserver log_path.' do
    it {
      should contain_cassandra__opscenter__setting('webserver log_path').with({
        'path'         => '/etc/opscenter/opscenterd.conf',
        'section'      => 'webserver',
        'setting'      => 'log_path',
        'value'        => nil
      })
    }
  end

  context 'Test webserver port.' do
    it {
      should contain_cassandra__opscenter__setting('webserver port').with({
        'path'         => '/etc/opscenter/opscenterd.conf',
        'section'      => 'webserver',
        'setting'      => 'port',
        'value'        => 8888
      })
    }
  end

  context 'Test webserver ssl_certfile.' do
    it {
      should contain_cassandra__opscenter__setting('webserver ssl_certfile').with({
        'path'         => '/etc/opscenter/opscenterd.conf',
        'section'      => 'webserver',
        'setting'      => 'ssl_certfile',
        'value'        => nil
      })
    }
  end

  context 'Test webserver ssl_keyfile.' do
    it {
      should contain_cassandra__opscenter__setting('webserver ssl_keyfile').with({
        'path'         => '/etc/opscenter/opscenterd.conf',
        'section'      => 'webserver',
        'setting'      => 'ssl_keyfile',
        'value'        => nil
      })
    }
  end

  context 'Test webserver ssl_port.' do
    it {
      should contain_cassandra__opscenter__setting('webserver ssl_port').with({
        'path'         => '/etc/opscenter/opscenterd.conf',
        'section'      => 'webserver',
        'setting'      => 'ssl_port',
        'value'        => nil
      })
    }
  end

  context 'Test webserver staticdir.' do
    it {
      should contain_cassandra__opscenter__setting('webserver staticdir').with({
        'path'         => '/etc/opscenter/opscenterd.conf',
        'section'      => 'webserver',
        'setting'      => 'staticdir',
        'value'        => nil
      })
    }
  end

  context 'Test webserver sub_process_timeout.' do
    it {
      should contain_cassandra__opscenter__setting('webserver sub_process_timeout').with({
        'path'         => '/etc/opscenter/opscenterd.conf',
        'section'      => 'webserver',
        'setting'      => 'sub_process_timeout',
        'value'        => nil
      })
    }
  end

  context 'Test webserver tarball_process_timeout.' do
    it {
      should contain_cassandra__opscenter__setting('webserver tarball_process_timeout').with({
        'path'         => '/etc/opscenter/opscenterd.conf',
        'section'      => 'webserver',
        'setting'      => 'tarball_process_timeout',
        'value'        => nil
      })
    }
  end
end
