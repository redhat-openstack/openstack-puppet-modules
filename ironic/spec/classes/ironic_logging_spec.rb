require 'spec_helper'

describe 'ironic::logging' do

  let :params do
    {
    }
  end

  let :log_params do
    {
      :logging_context_format_string => '%(asctime)s.%(msecs)03d %(process)d %(levelname)s %(name)s [%(request_id)s %(user_identity)s] %(instance)s%(message)s',
      :logging_default_format_string => '%(asctime)s.%(msecs)03d %(process)d %(levelname)s %(name)s [-] %(instance)s%(message)s',
      :logging_debug_format_suffix => '%(funcName)s %(pathname)s:%(lineno)d',
      :logging_exception_prefix => '%(asctime)s.%(msecs)03d %(process)d TRACE %(name)s %(instance)s',
      :log_config_append => '/etc/ironic/logging.conf',
      :publish_errors => true,
      :default_log_levels => {
        'amqp' => 'WARN', 'amqplib' => 'WARN', 'boto' => 'WARN',
        'qpid' => 'WARN', 'sqlalchemy' => 'WARN', 'suds' => 'INFO',
        'iso8601' => 'WARN',
        'requests.packages.urllib3.connectionpool' => 'WARN' },
     :fatal_deprecations => true,
     :instance_format => '[instance: %(uuid)s] ',
     :instance_uuid_format => '[instance: %(uuid)s] ',
     :log_date_format => '%Y-%m-%d %H:%M:%S',
     :use_syslog => true,
     :use_stderr => false,
     :log_facility => 'LOG_FOO',
     :log_dir => '/var/log',
     :verbose => true,
     :debug => true,
    }
  end

  shared_examples_for 'ironic-logging' do

    context 'with basic logging options and default settings' do
      it_configures  'basic default logging settings'
    end

    context 'with basic logging options and non-default settings' do
      before { params.merge!( log_params ) }
      it_configures 'basic non-default logging settings'
    end

    context 'with extended logging options' do
      before { params.merge!( log_params ) }
      it_configures 'logging params set'
    end

    context 'without extended logging options' do
      it_configures 'logging params unset'
    end

  end

  shared_examples 'basic default logging settings' do
    it 'configures ironic logging settins with default values' do
      is_expected.to contain_ironic_config('DEFAULT/use_syslog').with(:value => '<SERVICE DEFAULT>')
      is_expected.to contain_ironic_config('DEFAULT/use_stderr').with(:value => '<SERVICE DEFAULT>')
      is_expected.to contain_ironic_config('DEFAULT/log_dir').with(:value => '/var/log/ironic')
      is_expected.to contain_ironic_config('DEFAULT/verbose').with(:value => '<SERVICE DEFAULT>')
      is_expected.to contain_ironic_config('DEFAULT/debug').with(:value => '<SERVICE DEFAULT>')
    end
  end

  shared_examples 'basic non-default logging settings' do
    it 'configures ironic logging settins with non-default values' do
      is_expected.to contain_ironic_config('DEFAULT/use_syslog').with(:value => 'true')
      is_expected.to contain_ironic_config('DEFAULT/use_stderr').with(:value => 'false')
      is_expected.to contain_ironic_config('DEFAULT/syslog_log_facility').with(:value => 'LOG_FOO')
      is_expected.to contain_ironic_config('DEFAULT/log_dir').with(:value => '/var/log')
      is_expected.to contain_ironic_config('DEFAULT/verbose').with(:value => 'true')
      is_expected.to contain_ironic_config('DEFAULT/debug').with(:value => 'true')
    end
  end

  shared_examples_for 'logging params set' do
    it 'enables logging params' do
      is_expected.to contain_ironic_config('DEFAULT/logging_context_format_string').with_value(
        '%(asctime)s.%(msecs)03d %(process)d %(levelname)s %(name)s [%(request_id)s %(user_identity)s] %(instance)s%(message)s')

      is_expected.to contain_ironic_config('DEFAULT/logging_default_format_string').with_value(
        '%(asctime)s.%(msecs)03d %(process)d %(levelname)s %(name)s [-] %(instance)s%(message)s')

      is_expected.to contain_ironic_config('DEFAULT/logging_debug_format_suffix').with_value(
        '%(funcName)s %(pathname)s:%(lineno)d')

      is_expected.to contain_ironic_config('DEFAULT/logging_exception_prefix').with_value(
       '%(asctime)s.%(msecs)03d %(process)d TRACE %(name)s %(instance)s')

      is_expected.to contain_ironic_config('DEFAULT/log_config_append').with_value(
        '/etc/ironic/logging.conf')
      is_expected.to contain_ironic_config('DEFAULT/publish_errors').with_value(
        true)

      is_expected.to contain_ironic_config('DEFAULT/default_log_levels').with_value(
        'amqp=WARN,amqplib=WARN,boto=WARN,iso8601=WARN,qpid=WARN,requests.packages.urllib3.connectionpool=WARN,sqlalchemy=WARN,suds=INFO')

      is_expected.to contain_ironic_config('DEFAULT/fatal_deprecations').with_value(
        true)

      is_expected.to contain_ironic_config('DEFAULT/instance_format').with_value(
        '[instance: %(uuid)s] ')

      is_expected.to contain_ironic_config('DEFAULT/instance_uuid_format').with_value(
        '[instance: %(uuid)s] ')

      is_expected.to contain_ironic_config('DEFAULT/log_date_format').with_value(
        '%Y-%m-%d %H:%M:%S')
    end
  end


  shared_examples_for 'logging params unset' do
   [ :logging_context_format_string, :logging_default_format_string,
     :logging_debug_format_suffix, :logging_exception_prefix,
     :log_config_append, :publish_errors,
     :default_log_levels, :fatal_deprecations,
     :instance_format, :instance_uuid_format,
     :log_date_format, ].each { |param|
        it { is_expected.to contain_ironic_config("DEFAULT/#{param}").with_value('<SERVICE DEFAULT>') }
      }
  end

  context 'on Debian platforms' do
    let :facts do
      @default_facts.merge({ :osfamily => 'Debian' })
    end

    it_configures 'ironic-logging'
  end

  context 'on RedHat platforms' do
    let :facts do
      @default_facts.merge({ :osfamily => 'RedHat' })
    end

    it_configures 'ironic-logging'
  end

end
