require 'spec_helper'
describe 'cassandra' do
  let(:pre_condition) { [
    'class apt () {}',
    'class apt::update () {}',
    'define apt::key ($id, $source) {}',
    'define apt::source ($location, $comment, $release, $include) {}',
    'define ini_setting($ensure = nil,
       $path,
       $section,
       $key_val_separator       = nil,
       $setting,
       $value                   = nil) {}',
  ] }

  context 'On an unknown OS with defaults for all parameters' do
    let :facts do
      {
        :osfamily => 'Darwin'
      }
    end

    it { should raise_error(Puppet::Error) }
  end

  context 'Test the default parameters' do
    let :facts do
      {
        :osfamily => 'RedHat'
      }
    end

    it {
      should contain_file('/etc/cassandra/default.conf/cassandra.yaml').with_content(/^key_cache_size_in_mb:$/)
    }

    it {
      should contain_class('cassandra').only_with(
        'authenticator' => 'AllowAllAuthenticator',
        'authorizer' => 'AllowAllAuthorizer',
        'auto_snapshot' => true,
        'batchlog_replay_throttle_in_kb' => 1024,
        'batch_size_warn_threshold_in_kb' => 5,
        'cas_contention_timeout_in_ms' => 1000,
        'cassandra_9822' => false,
        'cassandra_yaml_tmpl' => 'cassandra/cassandra.yaml.erb',
        'client_encryption_enabled' => false,
        'client_encryption_keystore' => 'conf/.keystore',
        'client_encryption_keystore_password' => 'cassandra',
        'cluster_name' => 'Test Cluster',
        'column_index_size_in_kb' => 64,
        'commitlog_directory' => '/var/lib/cassandra/commitlog',
        'commitlog_directory_mode' => '0750',
        'commitlog_segment_size_in_mb' => 32,
        'commitlog_sync' => 'periodic',
        'commitlog_sync_period_in_ms' => 10000,
        'commit_failure_policy' => 'stop',
        'compaction_throughput_mb_per_sec' => 16,
        'concurrent_counter_writes' => 32,
        'concurrent_reads' => 32,
        'concurrent_writes' => 32,
        'config_file_mode' => '0644',
        'config_path' => nil,
        'counter_cache_save_period' => 7200,
        'counter_cache_size_in_mb' => '',
        'counter_write_request_timeout_in_ms' => 5000,
        'cross_node_timeout' => false,
        'data_file_directories' => ['/var/lib/cassandra/data'],
        'data_file_directories_mode' => '0750',
        'dc' => 'DC1',
        'disk_failure_policy' => 'stop',
        'dynamic_snitch_badness_threshold' => 0.1,
        'dynamic_snitch_reset_interval_in_ms' => 600000,
        'dynamic_snitch_update_interval_in_ms' => 100,
        'endpoint_snitch' => 'SimpleSnitch',
        'fail_on_non_supported_os' => true,
        'hinted_handoff_enabled' => true,
        'hinted_handoff_throttle_in_kb' => 1024,
        'incremental_backups' => false,
        'index_summary_capacity_in_mb' => '',
        'index_summary_resize_interval_in_minutes' => 60,
        'inter_dc_tcp_nodelay' => false,
        'internode_compression' => 'all',
        'key_cache_save_period' => 14400,
        'key_cache_size_in_mb'  => '',
        'listen_address' => 'localhost',
        'manage_dsc_repo' => false,
        'max_hints_delivery_threads' => 2,
        'max_hint_window_in_ms' => 10800000,
        'native_transport_port' => 9042,
        'num_tokens' => 256,
        'package_ensure' => 'present',
        #'package_name' => nil,
        'partitioner' => 'org.apache.cassandra.dht.Murmur3Partitioner',
        'permissions_validity_in_ms' => 2000,
        #'prefer_local' => nil,
        'rack' => 'RAC1',
        'range_request_timeout_in_ms' => 10000,
        'read_request_timeout_in_ms' => 5000,
        'request_scheduler' => 'org.apache.cassandra.scheduler.NoScheduler',
        'request_timeout_in_ms' => 10000,
        'row_cache_save_period' => 0,
        'row_cache_size_in_mb' => 0,
        'rpc_address' => 'localhost',
        'rpc_port' => 9160,
        'rpc_server_type' => 'sync',
        'saved_caches_directory' => '/var/lib/cassandra/saved_caches',
        'saved_caches_directory_mode' => '0750',
        'seed_provider_class_name' => 'org.apache.cassandra.locator.SimpleSeedProvider',
        'seeds' => '127.0.0.1',
        'server_encryption_internode' => 'none',
        'server_encryption_keystore' => 'conf/.keystore',
        'server_encryption_keystore_password' => 'cassandra',
        'server_encryption_truststore' => 'conf/.truststore',
        'server_encryption_truststore_password' => 'cassandra',
        'service_enable' => true,
        'service_ensure' => 'running',
        'service_name' => 'cassandra',
        'service_refresh' => true,
        'snapshot_before_compaction' => false,
        'snitch_properties_file' => 'cassandra-rackdc.properties',
        'ssl_storage_port' => 7001,
        'sstable_preemptive_open_interval_in_mb' => 50,
        'start_native_transport' => true,
        'start_rpc' => true,
        'storage_port' => 7000,
        'tombstone_failure_threshold' => 100000,
        'tombstone_warn_threshold' => 1000,
        'trickle_fsync' => false,
        'trickle_fsync_interval_in_kb' => 10240,
        'truncate_request_timeout_in_ms' => 60000,
        'write_request_timeout_in_ms' => 2000,
      )
    }
  end

  context 'On an unsupported OS pleading tolerance (with dyslexia)' do
    let :facts do
      {
        :osfamily => 'Darwin'
      }
    end
    let :params do
      {
        :config_file_mode        => '0755',
        :config_path             => '/etc/cassandra',
        :fail_on_non_suppoted_os => false,
        :package_name            => 'cassandra'
      }
    end

    it { should compile }
  end

  context 'On an unsupported OS pleading tolerance' do
    let :facts do
      {
        :osfamily => 'Darwin'
      }
    end
    let :params do
      {
        :config_file_mode        => '0755',
        :config_path             => '/etc/cassandra',
        :fail_on_non_supported_os => false,
        :package_name            => 'cassandra'
      }
    end

    it {
      should contain_file('/etc/cassandra/cassandra.yaml').with({
        'mode' => '0755'
      })
    }
    it { should have_resource_count(8) }
  end

  context 'Test the dc and rack properties.' do
    let :facts do
      {
        :osfamily => 'RedHat'
      }
    end

    let :params do
      {
        :snitch_properties_file => 'cassandra-topology.properties',
        :dc                     => 'NYC',
        :rack                   => 'R101',
        :dc_suffix              => '_1_cassandra',
        :prefer_local           => 'true'
      }
    end
    it {
      should contain_ini_setting('rackdc.properties.dc').with({
        'path'    => '/etc/cassandra/default.conf/cassandra-topology.properties',
        'section' => '',
        'setting' => 'dc',
        'value'   => 'NYC'
      })
    }
    it {
      should contain_ini_setting('rackdc.properties.rack').with({
        'path'    => '/etc/cassandra/default.conf/cassandra-topology.properties',
        'section' => '',
        'setting' => 'rack',
        'value'   => 'R101'
      })
    }
    it {
      should contain_service('cassandra').that_subscribes_to('Ini_setting[rackdc.properties.dc_suffix]') 
      should contain_ini_setting('rackdc.properties.dc_suffix').with({
        'path'    => '/etc/cassandra/default.conf/cassandra-topology.properties',
        'section' => '',
        'setting' => 'dc_suffix',
        'value'   => '_1_cassandra'
      })
    }
    it {
      should contain_service('cassandra').that_subscribes_to('Ini_setting[rackdc.properties.prefer_local]') 
      should contain_ini_setting('rackdc.properties.prefer_local').with({
        'path'    => '/etc/cassandra/default.conf/cassandra-topology.properties',
        'section' => '',
        'setting' => 'prefer_local',
        'value'   => 'true'
      })
    }
  end

  context 'Ensure cassandra service can be stopped and disabled.' do
    let :facts do
      {
        :osfamily => 'Debian'
      }
    end

    let :params do
      {
        :service_ensure => 'stopped',
        :service_enable => 'false'
      }
    end
    it {
      should contain_service('cassandra').with({
        'ensure'    => 'stopped',
        'name'      => 'cassandra',
        'enable'    => 'false'
      })
    }
    it {
      should contain_service('cassandra').that_subscribes_to('File[/etc/cassandra/cassandra.yaml]') 
      should contain_service('cassandra').that_subscribes_to('Ini_setting[rackdc.properties.dc]') 
      should contain_service('cassandra').that_subscribes_to('Ini_setting[rackdc.properties.rack]') 
      should contain_service('cassandra').that_subscribes_to('Package[cassandra]') 
    }
  end
end
