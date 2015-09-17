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

  context 'Test the cassandra1.yml temlate.' do
    let :facts do
      {
        :osfamily => 'RedHat'
      }
    end

    let :params do
      {
        :authenticator                            => 'foo',
        :authorizer                               => 'foo',
        :auto_bootstrap                           => false,
        :auto_snapshot                            => 'foo',
        :cassandra_yaml_tmpl                      => 'cassandra/cassandra1.yaml.erb',
        :client_encryption_enabled                => 'foo',
        :client_encryption_keystore               => 'foo',
        :client_encryption_keystore_password      => 'foo',
        :cluster_name                             => 'foo',
        :config_path                              => '/etc',
        :disk_failure_policy                      => 'foo',
        :endpoint_snitch                          => 'foo',
        :hinted_handoff_enabled                   => 'foo',
        :incremental_backups                      => 'foo',
        :internode_compression                    => 'foo',
        :listen_address                           => 'foo',
        :native_transport_port                    => 'foo',
        :num_tokens                               => 'foo',
        :partitioner                              => 'foo',
        :rpc_address                              => 'foo',
        :rpc_port                                 => 'foo',
        :rpc_server_type                          => 'foo',
        :seeds                                    => 'foo',
        :server_encryption_internode              => 'foo',
        :server_encryption_keystore               => 'foo',
        :server_encryption_keystore_password      => 'foo',
        :server_encryption_truststore             => 'foo',
        :server_encryption_truststore_password    => 'foo',
        :snapshot_before_compaction               => 'foo',
        :ssl_storage_port                         => 'foo',
        :start_native_transport                   => 'foo',
        :start_rpc                                => 'foo',
        :storage_port                             => 'foo',
        :batchlog_replay_throttle_in_kb           => 'batchlog_replay_throttle_in_kb',
        :cas_contention_timeout_in_ms             => 'cas_contention_timeout_in_ms',
        :column_index_size_in_kb                  => 'column_index_size_in_kb',
        :commit_failure_policy                    => 'commit_failure_policy',
        :compaction_throughput_mb_per_sec         => 'compaction_throughput_mb_per_sec',
        :counter_cache_save_period                => 'counter_cache_save_period',
        :counter_write_request_timeout_in_ms      => 'counter_write_request_timeout_in_ms',
        :cross_node_timeout                       => 'cross_node_timeout',
        :dynamic_snitch_badness_threshold         => 'dynamic_snitch_badness_threshold',
        :dynamic_snitch_reset_interval_in_ms      => 'dynamic_snitch_reset_interval_in_ms',
        :dynamic_snitch_update_interval_in_ms     => 'dynamic_snitch_update_interval_in_ms',
        :hinted_handoff_throttle_in_kb            => 'hinted_handoff_throttle_in_kb',
        :index_summary_resize_interval_in_minutes => 'index_summary_resize_interval_in_minutes',
        :inter_dc_tcp_nodelay                     => 'inter_dc_tcp_nodelay',
        :max_hints_delivery_threads               => 'max_hints_delivery_threads',
        :max_hint_window_in_ms                    => 'max_hint_window_in_ms',
        :permissions_validity_in_ms               => 'permissions_validity_in_ms',
        :range_request_timeout_in_ms              => 'range_request_timeout_in_ms',
        :read_request_timeout_in_ms               => 'read_request_timeout_in_ms',
        :request_scheduler                        => 'request_scheduler',
        :request_timeout_in_ms                    => 'request_timeout_in_ms',
        :row_cache_save_period                    => 'row_cache_save_period',
        :row_cache_size_in_mb                     => 'row_cache_size_in_mb',
        :sstable_preemptive_open_interval_in_mb   => 'sstable_preemptive_open_interval_in_mb',
        :tombstone_failure_threshold              => 'tombstone_failure_threshold',
        :tombstone_warn_threshold                 => 'tombstone_warn_threshold',
        :trickle_fsync                            => 'trickle_fsync',
        :trickle_fsync_interval_in_kb             => 'trickle_fsync_interval_in_kb',
        :truncate_request_timeout_in_ms           => 'truncate_request_timeout_in_ms',
        :write_request_timeout_in_ms              => 'write_request_timeout_in_ms',
        :commitlog_directory                      => 'commitlog_directory',
        :saved_caches_directory                   => 'saved_caches_directory',
        :data_file_directories                    => ['datadir1', 'datadir2'],
        :initial_token => 'initial_token',
        :permissions_update_interval_in_ms => 'permissions_update_interval_in_ms',
        :row_cache_keys_to_save => 'row_cache_keys_to_save',
        :counter_cache_keys_to_save => 'counter_cache_keys_to_save',
        :memory_allocator => 'memory_allocator',
        :commitlog_sync => 'commitlog_sync',
        :commitlog_sync_batch_window_in_ms => 'commitlog_sync_batch_window_in_ms',
        :file_cache_size_in_mb => 'file_cache_size_in_mb',
        :memtable_heap_space_in_mb => 'memtable_heap_space_in_mb',
        :memtable_offheap_space_in_mb => 'memtable_offheap_space_in_mb',
        :memtable_cleanup_threshold => 'memtable_cleanup_threshold',
        :commitlog_total_space_in_mb => 'commitlog_total_space_in_mb',
        :memtable_flush_writers => 'memtable_flush_writers',
        :broadcast_address => 'broadcast_address',
        :internode_authenticator => 'internode_authenticator',
        :native_transport_max_threads => 'native_transport_max_threads',
        :native_transport_max_frame_size_in_mb => 'native_transport_max_frame_size_in_mb',
        :native_transport_max_concurrent_connections => 'native_transport_max_concurrent_connections',
        :native_transport_max_concurrent_connections_per_ip => 'native_transport_max_concurrent_connections_per_ip',
        :broadcast_rpc_address => 'broadcast_rpc_address',
        :rpc_min_threads => 'rpc_min_threads',
        :rpc_max_threads => 'rpc_max_threads',
        :rpc_send_buff_size_in_bytes => 'rpc_send_buff_size_in_bytes',
        :rpc_recv_buff_size_in_bytes => 'rpc_recv_buff_size_in_bytes',
        :internode_send_buff_size_in_bytes => 'internode_send_buff_size_in_bytes',
        :internode_recv_buff_size_in_bytes => 'internode_recv_buff_size_in_bytes',
        :concurrent_compactors => 'concurrent_compactors',
        :stream_throughput_outbound_megabits_per_sec => 'stream_throughput_outbound_megabits_per_sec',
        :inter_dc_stream_throughput_outbound_megabits_per_sec => 'inter_dc_stream_throughput_outbound_megabits_per_sec',
        :streaming_socket_timeout_in_ms => 'streaming_socket_timeout_in_ms',
        :phi_convict_threshold => 'phi_convict_threshold',
        :request_scheduler_options_throttle_limit => 'request_scheduler_options_throttle_limit',
        :request_scheduler_options_default_weight => 'request_scheduler_options_default_weight',
      }
    end

    it { should contain_file('/etc/cassandra.yaml').with_content(/authenticator: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/authorizer: foo/) }
    it {
      should contain_file('/etc/cassandra.yaml').with_content(/auto_bootstrap: false/)
    }
    it { should contain_file('/etc/cassandra.yaml').with_content(/auto_snapshot: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/enabled: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/keystore: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/keystore_password: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/cluster_name: 'foo'/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/disk_failure_policy: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/endpoint_snitch: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/hinted_handoff_enabled: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/incremental_backups: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/internode_compression: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/listen_address: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/native_transport_port: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/num_tokens: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/partitioner: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/rpc_address: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/rpc_port: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/rpc_server_type: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/ - seeds: "foo"/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/internode_encryption: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/keystore: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/keystore_password: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/truststore: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/truststore_password: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/snapshot_before_compaction: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/ssl_storage_port: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/start_native_transport: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/start_rpc: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/storage_port: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/column_index_size_in_kb: column_index_size_in_kb/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/compaction_throughput_mb_per_sec: compaction_throughput_mb_per_sec/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/cross_node_timeout: cross_node_timeout/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/dynamic_snitch_badness_threshold: dynamic_snitch_badness_threshold/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/dynamic_snitch_reset_interval_in_ms: dynamic_snitch_reset_interval_in_ms/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/dynamic_snitch_update_interval_in_ms: dynamic_snitch_update_interval_in_ms/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/hinted_handoff_throttle_in_kb: hinted_handoff_throttle_in_kb/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/inter_dc_tcp_nodelay: inter_dc_tcp_nodelay/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/max_hints_delivery_threads: max_hints_delivery_threads/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/max_hint_window_in_ms: max_hint_window_in_ms/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/permissions_validity_in_ms: permissions_validity_in_ms/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/range_request_timeout_in_ms: range_request_timeout_in_ms/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/read_request_timeout_in_ms: read_request_timeout_in_ms/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/request_scheduler: request_scheduler/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/request_timeout_in_ms: request_timeout_in_ms/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/row_cache_save_period: row_cache_save_period/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/row_cache_size_in_mb: row_cache_size_in_mb/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/trickle_fsync: trickle_fsync/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/trickle_fsync_interval_in_kb: trickle_fsync_interval_in_kb/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/truncate_request_timeout_in_ms: truncate_request_timeout_in_ms/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/write_request_timeout_in_ms: write_request_timeout_in_ms/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/commitlog_directory: commitlog_directory/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/saved_caches_directory: saved_caches_directory/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/    - datadir1/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/    - datadir2/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/initial_token: initial_token/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/row_cache_keys_to_save: row_cache_keys_to_save/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/commitlog_sync: commitlog_sync/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/commitlog_sync_batch_window_in_ms: commitlog_sync_batch_window_in_ms/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/commitlog_total_space_in_mb: commitlog_total_space_in_mb/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/memtable_flush_writers: memtable_flush_writers/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/broadcast_address: broadcast_address/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/internode_authenticator: internode_authenticator/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/native_transport_max_threads: native_transport_max_threads/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/rpc_min_threads: rpc_min_threads/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/rpc_max_threads: rpc_max_threads/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/rpc_send_buff_size_in_bytes: rpc_send_buff_size_in_bytes/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/rpc_recv_buff_size_in_bytes: rpc_recv_buff_size_in_bytes/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/internode_send_buff_size_in_bytes: internode_send_buff_size_in_bytes/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/internode_recv_buff_size_in_bytes: internode_recv_buff_size_in_bytes/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/concurrent_compactors: concurrent_compactors/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/stream_throughput_outbound_megabits_per_sec: stream_throughput_outbound_megabits_per_sec/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/streaming_socket_timeout_in_ms: streaming_socket_timeout_in_ms/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/phi_convict_threshold: phi_convict_threshold/) }
  end
end
