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
        'webserver_log_path'                => nil,
        'webserver_port'                    => 8888,
        'webserver_ssl_certfile'            => nil,
        'webserver_ssl_keyfile'             => nil,
        'webserver_ssl_port'                => nil,
        'webserver_staticdir'               => nil,
        'webserver_sub_process_timeout'     => nil,
        'webserver_tarball_process_timeout' => nil
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
