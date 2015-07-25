require 'spec_helper'
describe 'cassandra::opscenter' do
  let(:pre_condition) { [
    'define ini_setting ($ensure = nil,
      $path = nil,
      $section = nil,
      $key_val_separator = nil,
      $setting = nil,
      $value = nil) {}'
  ] }

  context 'Test params for cassandra::opscenter.' do
    let :params do
      {
        :logging_level                     => 42,
        :logging_log_length                => 42,
        :logging_log_path                  => 42,
        :logging_max_rotate                => 42,
        :logging_resource_usage_interval   => 42,
        :stat_reporter_initial_sleep       => 42,
        :stat_reporter_interval            => 42,
        :stat_reporter_report_file         => 42,
        :stat_reporter_ssl_key             => 42,
        :webserver_log_path                => 42,
        :webserver_ssl_certfile            => 42,
        :webserver_ssl_keyfile             => 42,
        :webserver_ssl_port                => 42,
        :webserver_staticdir               => 42,
        :webserver_sub_process_timeout     => 42,
        :webserver_tarball_process_timeout => 42
      }
    end

    it {
      should contain_class('cassandra::opscenter').with({
        'authentication_enabled'            => 'False',
        'ensure'                            => 'present',
        'config_file'                       => '/etc/opscenter/opscenterd.conf',
        'package_name'                      => 'opscenter',
        'service_enable'                    => 'true',
        'service_ensure'                    => 'running',
        'service_name'                      => 'opscenterd',
        'logging_level'                     => 42,
        'logging_log_length'                => 42,
        'logging_log_path'                  => 42,
        'logging_max_rotate'                => 42,
        'logging_resource_usage_interval'   => 42,
        'stat_reporter_initial_sleep'       => 42,
        'stat_reporter_interval'            => 42,
        'stat_reporter_report_file'         => 42,
        'stat_reporter_ssl_key'             => 42,
        'webserver_interface'               => '0.0.0.0',
        'webserver_log_path'                => 42,
        'webserver_port'                    => 8888,
        'webserver_ssl_certfile'            => 42,
        'webserver_ssl_keyfile'             => 42,
        'webserver_ssl_port'                => 42,
        'webserver_staticdir'               => 42,
        'webserver_sub_process_timeout'     => 42,
        'webserver_tarball_process_timeout' => 42
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
