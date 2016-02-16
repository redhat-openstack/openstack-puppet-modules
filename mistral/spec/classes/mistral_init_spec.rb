require 'spec_helper'
describe 'mistral' do
  let :req_params do
    {
      :rabbit_password     => 'guest',
      :database_connection => 'mysql://user:password@host/database',
      :keystone_password   => 'foo',
    }
  end

  let :facts do
    OSDefaults.get_facts({
      :osfamily               => 'Debian',
      :operatingsystem        => 'Debian',
      :operatingsystemrelease => 'jessie',
    })
  end

  describe 'with only required params' do
    let :params do
      req_params
    end

    it { is_expected.to contain_class('mistral::logging') }
    it { is_expected.to contain_class('mistral::params') }
    it { is_expected.to contain_class('mysql::bindings::python') }

    it 'should contain default config' do
      is_expected.to contain_mistral_config('DEFAULT/rpc_backend').with(:value => 'rabbit')
      is_expected.to contain_mistral_config('DEFAULT/control_exchange').with(:value => 'openstack')
      is_expected.to contain_mistral_config('DEFAULT/report_interval').with(:value => '<SERVICE DEFAULT>')
      is_expected.to contain_mistral_config('DEFAULT/service_down_time').with(:value => '<SERVICE DEFAULT>')
      is_expected.to contain_mistral_config('oslo_messaging_rabbit/rabbit_password').with(:value => 'guest', :secret => true)
      is_expected.to contain_mistral_config('oslo_messaging_rabbit/rabbit_host').with(:value => '127.0.0.1')
      is_expected.to contain_mistral_config('oslo_messaging_rabbit/rabbit_port').with(:value => '5672')
      is_expected.to contain_mistral_config('oslo_messaging_rabbit/rabbit_hosts').with(:value => '127.0.0.1:5672')
      is_expected.to contain_mistral_config('oslo_messaging_rabbit/rabbit_ha_queues').with(:value => false)
      is_expected.to contain_mistral_config('oslo_messaging_rabbit/rabbit_virtual_host').with(:value => '/')
      is_expected.to contain_mistral_config('oslo_messaging_rabbit/heartbeat_timeout_threshold').with_value('0')
      is_expected.to contain_mistral_config('oslo_messaging_rabbit/heartbeat_rate').with_value('2')
      is_expected.to contain_mistral_config('oslo_messaging_rabbit/rabbit_userid').with(:value => 'guest')
      is_expected.to contain_mistral_config('oslo_messaging_rabbit/kombu_reconnect_delay').with(:value => '<SERVICE DEFAULT>')
      is_expected.to contain_mistral_config('coordination/backend_url').with(:value => '<SERVICE DEFAULT>')
      is_expected.to contain_mistral_config('coordination/heartbeat_interval').with(:value => '<SERVICE DEFAULT>')
      is_expected.to contain_mistral_config('keystone_authtoken/auth_uri').with(
       :value => 'http://localhost:5000/'
      )
      is_expected.to contain_mistral_config('keystone_authtoken/identity_uri').with(
       :value => 'http://localhost:35357/'
      )
      is_expected.to contain_mistral_config('keystone_authtoken/admin_tenant_name').with(
       :value => 'services'
      )
      is_expected.to contain_mistral_config('keystone_authtoken/admin_user').with(
       :value => 'mistral'
      )
      is_expected.to contain_mistral_config('keystone_authtoken/admin_password').with(
       :value => 'foo'
      )
    end

  end
  describe 'with modified rabbit_hosts' do
    let :params do
      req_params.merge({'rabbit_hosts' => ['rabbit1:5672', 'rabbit2:5672']})
    end

    it 'should contain many' do
      is_expected.to contain_mistral_config('oslo_messaging_rabbit/rabbit_host').with(:value => nil)
      is_expected.to contain_mistral_config('oslo_messaging_rabbit/rabbit_port').with(:value => nil)
      is_expected.to contain_mistral_config('oslo_messaging_rabbit/rabbit_hosts').with(:value => 'rabbit1:5672,rabbit2:5672')
      is_expected.to contain_mistral_config('oslo_messaging_rabbit/rabbit_ha_queues').with(:value => true)
    end
  end

  describe 'with a single rabbit_hosts entry' do
    let :params do
      req_params.merge({'rabbit_hosts' => ['rabbit1:5672']})
    end

    it 'should contain many' do
      is_expected.to contain_mistral_config('oslo_messaging_rabbit/rabbit_host').with(:value => nil)
      is_expected.to contain_mistral_config('oslo_messaging_rabbit/rabbit_port').with(:value => nil)
      is_expected.to contain_mistral_config('oslo_messaging_rabbit/rabbit_hosts').with(:value => 'rabbit1:5672')
      is_expected.to contain_mistral_config('oslo_messaging_rabbit/rabbit_ha_queues').with(:value => false)
    end
  end

  describe 'a single rabbit_host with enable ha queues' do
    let :params do
      req_params.merge({'rabbit_ha_queues' => true})
    end

    it 'should contain rabbit_ha_queues' do
      is_expected.to contain_mistral_config('oslo_messaging_rabbit/rabbit_ha_queues').with(:value => true)
    end
  end

  describe 'with rabbitmq heartbeats' do
    let :params do
      req_params.merge({'rabbit_heartbeat_timeout_threshold' => '60', 'rabbit_heartbeat_rate' => '10'})
    end

    it 'should contain heartbeat config' do
      is_expected.to contain_mistral_config('oslo_messaging_rabbit/heartbeat_timeout_threshold').with_value('60')
      is_expected.to contain_mistral_config('oslo_messaging_rabbit/heartbeat_rate').with_value('10')
    end
  end

  describe 'with SSL enabled with kombu' do
    let :params do
      req_params.merge!({
        :rabbit_use_ssl     => true,
        :kombu_ssl_ca_certs => '/path/to/ssl/ca/certs',
        :kombu_ssl_certfile => '/path/to/ssl/cert/file',
        :kombu_ssl_keyfile  => '/path/to/ssl/keyfile',
        :kombu_ssl_version  => 'TLSv1'
      })
    end

    it do
      is_expected.to contain_mistral_config('oslo_messaging_rabbit/rabbit_use_ssl').with_value('true')
      is_expected.to contain_mistral_config('oslo_messaging_rabbit/kombu_ssl_ca_certs').with_value('/path/to/ssl/ca/certs')
      is_expected.to contain_mistral_config('oslo_messaging_rabbit/kombu_ssl_certfile').with_value('/path/to/ssl/cert/file')
      is_expected.to contain_mistral_config('oslo_messaging_rabbit/kombu_ssl_keyfile').with_value('/path/to/ssl/keyfile')
      is_expected.to contain_mistral_config('oslo_messaging_rabbit/kombu_ssl_version').with_value('TLSv1')
    end
  end

  describe 'with SSL enabled without kombu' do
    let :params do
      req_params.merge!({
        :rabbit_use_ssl     => true,
      })
    end

    it do
      is_expected.to contain_mistral_config('oslo_messaging_rabbit/rabbit_use_ssl').with_value('true')
      is_expected.to contain_mistral_config('oslo_messaging_rabbit/kombu_ssl_ca_certs').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_mistral_config('oslo_messaging_rabbit/kombu_ssl_certfile').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_mistral_config('oslo_messaging_rabbit/kombu_ssl_keyfile').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_mistral_config('oslo_messaging_rabbit/kombu_ssl_version').with_value('<SERVICE DEFAULT>')
    end
  end

  describe 'with SSL disabled' do
    let :params do
      req_params.merge!({
        :rabbit_use_ssl     => false,
        :kombu_ssl_ca_certs => '<SERVICE DEFAULT>',
        :kombu_ssl_certfile => '<SERVICE DEFAULT>',
        :kombu_ssl_keyfile  => '<SERVICE DEFAULT>',
        :kombu_ssl_version  => '<SERVICE DEFAULT>'
      })
    end

    it do
      is_expected.to contain_mistral_config('oslo_messaging_rabbit/rabbit_use_ssl').with_value('false')
      is_expected.to contain_mistral_config('oslo_messaging_rabbit/kombu_ssl_ca_certs').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_mistral_config('oslo_messaging_rabbit/kombu_ssl_certfile').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_mistral_config('oslo_messaging_rabbit/kombu_ssl_keyfile').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_mistral_config('oslo_messaging_rabbit/kombu_ssl_version').with_value('<SERVICE DEFAULT>')
    end
  end

  describe 'with amqp_durable_queues disabled' do
    let :params do
      req_params
    end

    it { is_expected.to contain_mistral_config('oslo_messaging_rabbit/amqp_durable_queues').with_value(false) }
  end

  describe 'with amqp_durable_queues enabled' do
    let :params do
      req_params.merge({
        :amqp_durable_queues => true,
      })
    end

    it { is_expected.to contain_mistral_config('oslo_messaging_rabbit/amqp_durable_queues').with_value(true) }
  end

  describe 'with postgresql' do
    let :params do
      req_params.merge({
        :database_connection => 'postgresql://user:drowssap@host/database',
        :rabbit_password     => 'guest',
      })
    end

    it { is_expected.to_not contain_class('mysql::python') }
    it { is_expected.to_not contain_class('mysql::bindings') }
    it { is_expected.to_not contain_class('mysql::bindings::python') }
  end

  describe 'with coordination' do
    let :params do
      req_params.merge({
        :coordination_backend_url        => 'redis://127.0.0.1',
        :coordination_heartbeat_interval => '10.0',
      })
    end

    it 'should contain coordination config' do
      is_expected.to contain_mistral_config('coordination/backend_url').with(:value => 'redis://127.0.0.1')
      is_expected.to contain_mistral_config('coordination/heartbeat_interval').with(:value => '10.0')
    end
  end

end
