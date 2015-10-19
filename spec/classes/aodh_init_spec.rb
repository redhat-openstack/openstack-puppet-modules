require 'spec_helper'

describe 'aodh' do

  shared_examples 'aodh' do

    context 'with default parameters' do
     it 'contains the logging class' do
       is_expected.to contain_class('aodh::logging')
     end

      it 'installs packages' do
        is_expected.to contain_package('aodh').with(
          :name   => platform_params[:aodh_common_package],
          :ensure => 'present',
          :tag    => ['openstack', 'aodh-package']
        )
      end

      it 'configures rabbit' do
        is_expected.to contain_aodh_config('DEFAULT/rpc_backend').with_value('rabbit')
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/rabbit_host').with_value('localhost')
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/rabbit_password').with_value('guest').with_secret(true)
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/rabbit_port').with_value('5672')
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/rabbit_userid').with_value('guest')
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/rabbit_virtual_host').with_value('/')
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/heartbeat_timeout_threshold').with_value('0')
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/heartbeat_rate').with_value('2')
        is_expected.to contain_aodh_config('DEFAULT/notification_driver').with_ensure('absent')
      end
    end

    context 'with overridden parameters' do
      let :params do
        { :verbose                            => true,
          :debug                              => true,
          :rabbit_host                        => 'rabbit',
          :rabbit_userid                      => 'rabbit_user',
          :rabbit_port                        => '5673',
          :rabbit_password                    => 'password',
          :rabbit_ha_queues                   => 'undef',
          :rabbit_heartbeat_timeout_threshold => '60',
          :rabbit_heartbeat_rate              => '10',
          :ensure_package                     => '2012.1.1-15.el6',
          :notification_driver                => 'ceilometer.compute.aodh_notifier',
          :notification_topics                => 'openstack' }
      end

      it 'configures rabbit' do
        is_expected.to contain_aodh_config('DEFAULT/rpc_backend').with_value('rabbit')
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/rabbit_host').with_value('rabbit')
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/rabbit_password').with_value('password').with_secret(true)
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/rabbit_port').with_value('5673')
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/rabbit_userid').with_value('rabbit_user')
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/rabbit_virtual_host').with_value('/')
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/heartbeat_timeout_threshold').with_value('60')
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/heartbeat_rate').with_value('10')
      end

      it 'configures various things' do
        is_expected.to contain_aodh_config('DEFAULT/notification_driver').with_value('ceilometer.compute.aodh_notifier')
        is_expected.to contain_aodh_config('DEFAULT/notification_topics').with_value('openstack')
      end

      context 'with multiple notification_driver' do
        before { params.merge!( :notification_driver => ['ceilometer.compute.aodh_notifier', 'aodh.openstack.common.notifier.rpc_notifier']) }

        it { is_expected.to contain_aodh_config('DEFAULT/notification_driver').with_value(
          'ceilometer.compute.aodh_notifier,aodh.openstack.common.notifier.rpc_notifier'
        ) }
      end

    end

    context 'with rabbit_hosts parameter' do
      let :params do
        { :rabbit_hosts => ['rabbit:5673', 'rabbit2:5674'] }
      end

      it 'configures rabbit' do
        is_expected.to_not contain_aodh_config('oslo_messaging_rabbit/rabbit_host')
        is_expected.to_not contain_aodh_config('oslo_messaging_rabbit/rabbit_port')
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/rabbit_hosts').with_value('rabbit:5673,rabbit2:5674')
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/rabbit_ha_queues').with_value(true)
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/rabbit_use_ssl').with_value(false)
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/kombu_reconnect_delay').with_value('1.0')
        is_expected.to contain_aodh_config('DEFAULT/amqp_durable_queues').with_value(false)
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/kombu_ssl_ca_certs').with_ensure('absent')
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/kombu_ssl_certfile').with_ensure('absent')
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/kombu_ssl_keyfile').with_ensure('absent')
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/kombu_ssl_version').with_ensure('absent')
      end
    end

    context 'with rabbit_hosts parameter (one server)' do
      let :params do
        { :rabbit_hosts => ['rabbit:5673'] }
      end

      it 'configures rabbit' do
        is_expected.to_not contain_aodh_config('oslo_messaging_rabbit/rabbit_host')
        is_expected.to_not contain_aodh_config('oslo_messaging_rabbit/rabbit_port')
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/rabbit_hosts').with_value('rabbit:5673')
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/rabbit_ha_queues').with_value(true)
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/rabbit_use_ssl').with_value(false)
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/kombu_reconnect_delay').with_value('1.0')
        is_expected.to contain_aodh_config('DEFAULT/amqp_durable_queues').with_value(false)
      end
    end

    context 'with kombu_reconnect_delay set to 5.0' do
      let :params do
        { :kombu_reconnect_delay => '5.0' }
      end

      it 'configures rabbit' do
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/kombu_reconnect_delay').with_value('5.0')
      end
    end

    context 'with rabbit_ha_queues set to true' do
      let :params do
        { :rabbit_ha_queues => 'true' }
      end

      it 'configures rabbit' do
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/rabbit_ha_queues').with_value(true)
      end
    end

    context 'with rabbit_ha_queues set to false and with rabbit_hosts' do
      let :params do
        { :rabbit_ha_queues => 'false',
          :rabbit_hosts => ['rabbit:5673'] }
      end

      it 'configures rabbit' do
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/rabbit_ha_queues').with_value(false)
      end
    end

    context 'with amqp_durable_queues parameter' do
      let :params do
        { :rabbit_hosts => ['rabbit:5673'],
          :amqp_durable_queues => 'true' }
      end

      it 'configures rabbit' do
        is_expected.to_not contain_aodh_config('oslo_messaging_rabbit/rabbit_host')
        is_expected.to_not contain_aodh_config('oslo_messaging_rabbit/rabbit_port')
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/rabbit_hosts').with_value('rabbit:5673')
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/rabbit_ha_queues').with_value(true)
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/rabbit_use_ssl').with_value(false)
        is_expected.to contain_aodh_config('DEFAULT/amqp_durable_queues').with_value(true)
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/kombu_ssl_ca_certs').with_ensure('absent')
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/kombu_ssl_certfile').with_ensure('absent')
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/kombu_ssl_keyfile').with_ensure('absent')
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/kombu_ssl_version').with_ensure('absent')
      end
    end

    context 'with rabbit ssl enabled with kombu' do
      let :params do
        { :rabbit_hosts       => ['rabbit:5673'],
          :rabbit_use_ssl     => 'true',
          :kombu_ssl_ca_certs => '/etc/ca.cert',
          :kombu_ssl_certfile => '/etc/certfile',
          :kombu_ssl_keyfile  => '/etc/key',
          :kombu_ssl_version  => 'TLSv1', }
      end

      it 'configures rabbit' do
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/rabbit_use_ssl').with_value(true)
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/kombu_ssl_ca_certs').with_value('/etc/ca.cert')
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/kombu_ssl_certfile').with_value('/etc/certfile')
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/kombu_ssl_keyfile').with_value('/etc/key')
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/kombu_ssl_version').with_value('TLSv1')
      end
    end

    context 'with rabbit ssl enabled without kombu' do
      let :params do
        { :rabbit_hosts       => ['rabbit:5673'],
          :rabbit_use_ssl     => 'true', }
      end

      it 'configures rabbit' do
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/rabbit_use_ssl').with_value(true)
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/kombu_ssl_ca_certs').with_ensure('absent')
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/kombu_ssl_certfile').with_ensure('absent')
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/kombu_ssl_keyfile').with_ensure('absent')
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/kombu_ssl_version').with_value('TLSv1')
      end
    end

    context 'with rabbit ssl disabled' do
      let :params do
        {
          :rabbit_password    => 'pass',
          :rabbit_use_ssl     => false,
          :kombu_ssl_version  => 'TLSv1',
        }
      end

      it 'configures rabbit' do
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/rabbit_use_ssl').with_value('false')
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/kombu_ssl_ca_certs').with_ensure('absent')
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/kombu_ssl_certfile').with_ensure('absent')
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/kombu_ssl_keyfile').with_ensure('absent')
        is_expected.to contain_aodh_config('oslo_messaging_rabbit/kombu_ssl_version').with_ensure('absent')
      end
    end

    context 'with qpid rpc_backend' do
      let :params do
        { :rpc_backend => 'qpid' }
      end

      context 'with default parameters' do
        it 'configures qpid' do
          is_expected.to contain_aodh_config('DEFAULT/rpc_backend').with_value('qpid')
          is_expected.to contain_aodh_config('oslo_messaging_qpid/qpid_hostname').with_value('localhost')
          is_expected.to contain_aodh_config('oslo_messaging_qpid/qpid_port').with_value('5672')
          is_expected.to contain_aodh_config('oslo_messaging_qpid/qpid_username').with_value('guest')
          is_expected.to contain_aodh_config('oslo_messaging_qpid/qpid_password').with_value('guest').with_secret(true)
          is_expected.to contain_aodh_config('oslo_messaging_qpid/qpid_heartbeat').with_value('60')
          is_expected.to contain_aodh_config('oslo_messaging_qpid/qpid_protocol').with_value('tcp')
          is_expected.to contain_aodh_config('oslo_messaging_qpid/qpid_tcp_nodelay').with_value(true)
        end
      end

      context 'with qpid_password parameter (without qpid_sasl_mechanisms)' do
        before do
          params.merge!({ :qpid_password => 'guest' })
        end
        it { is_expected.to contain_aodh_config('oslo_messaging_qpid/qpid_sasl_mechanisms').with_ensure('absent') }
      end

      context 'with qpid_password parameter (with qpid_sasl_mechanisms)' do
        before do
          params.merge!({
            :qpid_password        => 'guest',
            :qpid_sasl_mechanisms => 'A'
          })
        end
        it { is_expected.to contain_aodh_config('oslo_messaging_qpid/qpid_sasl_mechanisms').with_value('A') }
      end

      context 'with qpid_password parameter (with array of qpid_sasl_mechanisms)' do
        before do
          params.merge!({
            :qpid_password        => 'guest',
            :qpid_sasl_mechanisms => [ 'DIGEST-MD5', 'GSSAPI', 'PLAIN' ]
          })
        end
        it { is_expected.to contain_aodh_config('oslo_messaging_qpid/qpid_sasl_mechanisms').with_value('DIGEST-MD5 GSSAPI PLAIN') }
      end
    end

    context 'with qpid rpc_backend with old parameter' do
      let :params do
        { :rpc_backend => 'aodh.openstack.common.rpc.impl_qpid' }
      end
      it { is_expected.to contain_aodh_config('DEFAULT/rpc_backend').with_value('aodh.openstack.common.rpc.impl_qpid') }
    end

    context 'with rabbitmq rpc_backend with old parameter' do
      let :params do
        { :rpc_backend => 'aodh.openstack.common.rpc.impl_kombu' }
      end
      it { is_expected.to contain_aodh_config('DEFAULT/rpc_backend').with_value('aodh.openstack.common.rpc.impl_kombu') }
    end
  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily        => 'Debian',
        :operatingsystem => 'Debian' }
    end

    let :platform_params do
      { :aodh_common_package => 'aodh-common' }
    end

    it_behaves_like 'aodh'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    let :platform_params do
      { :aodh_common_package => 'openstack-aodh-common' }
    end

    it_behaves_like 'aodh'
  end

end
