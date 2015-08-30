require 'spec_helper'
describe 'cassandra::opscenter::setting' do
  let(:pre_condition) { [
    'define ini_setting($ensure = nil,
       $path                    = nil,
       $section                 = nil,
       $key_val_separator       = nil,
       $setting                 = nil,
       $value                   = nil) {}'
  ] }

  context 'Test that settings can be set.' do
    let(:title) { 'section setting' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'section',
        :setting => 'setting',
        :value   => 'value',
      }
    end

    it {
      should contain_ini_setting('section setting').with({
        'value' => 'value',
      })
    }

    it {
      should_not contain_cassandra__opscenter__setting('agents agent_certfile')
    }

    it {
      should_not contain_cassandra__opscenter__setting('agents agent_certfile')
    }

    it {
      should_not contain_cassandra__opscenter__setting('agents agent_keyfile')
    }

    it {
      should_not contain_cassandra__opscenter__setting('agents agent_keyfile_raw')
    }

    it {
      should_not contain_cassandra__opscenter__setting('agents config_sleep')
    }

    it {
      should_not contain_cassandra__opscenter__setting('agents fingerprint_throttle')
    }

    it {
      should_not contain_cassandra__opscenter__setting('agents incoming_interface')
    }

    it {
      should_not contain_cassandra__opscenter__setting('agents incoming_port')
    }

    it {
      should_not contain_cassandra__opscenter__setting('agents install_throttle')
    }

    it {
      should_not contain_cassandra__opscenter__setting('agents not_seen_threshold')
    }

    it {
      should_not contain_cassandra__opscenter__setting('agents path_to_deb')
    }

    it {
      should_not contain_cassandra__opscenter__setting('agents path_to_find_java')
    }

    it {
      should_not contain_cassandra__opscenter__setting('agents path_to_installscript')
    }

    it {
      should_not contain_cassandra__opscenter__setting('agents path_to_rpm')
    }

    it {
      should_not contain_cassandra__opscenter__setting('agents path_to_sudowrap')
    }

    it {
      should_not contain_cassandra__opscenter__setting('agents reported_interface')
    }

    it {
      should_not contain_cassandra__opscenter__setting('agents runs_sudo')
    }

    it {
      should_not contain_cassandra__opscenter__setting('agents scp_executable')
    }

    it {
      should_not contain_cassandra__opscenter__setting('agents ssh_executable')
    }

    it {
      should_not contain_cassandra__opscenter__setting('agents ssh_keygen_executable')
    }

    it {
      should_not contain_cassandra__opscenter__setting('agents ssh_keyscan_executable')
    }

    it {
      should_not contain_cassandra__opscenter__setting('agents ssh_port')
    }

    it {
      should_not contain_cassandra__opscenter__setting('agents ssh_sys_known_hosts_file')
    }

    it {
      should_not contain_cassandra__opscenter__setting('agents ssh_user_known_hosts_file')
    }

    it {
      should_not contain_cassandra__opscenter__setting('agents ssl_certfile')
    }

    it {
      should_not contain_cassandra__opscenter__setting('agents ssl_keyfile')
    }

    it {
      should_not contain_cassandra__opscenter__setting('agents tmp_dir')
    }

    it {
      should_not contain_cassandra__opscenter__setting('agents use_ssl')
    }

    it {
      should_not contain_cassandra__opscenter__setting('authentication audit_auth')
    }

    it {
      should_not contain_cassandra__opscenter__setting('authentication audit_pattern')
    }

    it {
      should_not contain_cassandra__opscenter__setting('authentication authentication_method')
    }

    it {
      should_not contain_cassandra__opscenter__setting('authentication enabled')
    }

    it {
      should_not contain_cassandra__opscenter__setting('authentication passwd_db')
    }

    it {
      should_not contain_cassandra__opscenter__setting('authentication timeout')
    }

    it {
      should_not contain_cassandra__opscenter__setting('cloud accepted_certs')
    }

    it {
      should_not contain_cassandra__opscenter__setting('clusters add_cluster_timeout')
    }

    it {
      should_not contain_cassandra__opscenter__setting('clusters startup_sleep')
    }

    it {
      should_not contain_cassandra__opscenter__setting('definitions auto_update')
    }

    it {
      should_not contain_cassandra__opscenter__setting('definitions definitions_dir')
    }

    it {
      should_not contain_cassandra__opscenter__setting('definitions download_filename')
    }

    it {
      should_not contain_cassandra__opscenter__setting('definitions download_host')
    }

    it {
      should_not contain_cassandra__opscenter__setting('definitions download_port')
    }

    it {
      should_not contain_cassandra__opscenter__setting('definitions hash_filename')
    }

    it {
      should_not contain_cassandra__opscenter__setting('definitions sleep')
    }

    it {
      should_not contain_cassandra__opscenter__setting('definitions ssl_certfile')
    }

    it {
      should_not contain_cassandra__opscenter__setting('definitions use_ssl')
    }

    it {
      should_not contain_cassandra__opscenter__setting('failover failover_configuration_directory')
    }

    it {
      should_not contain_cassandra__opscenter__setting('failover heartbeat_fail_window')
    }

    it {
      should_not contain_cassandra__opscenter__setting('failover heartbeat_period')
    }

    it {
      should_not contain_cassandra__opscenter__setting('failover heartbeat_reply_period')
    }

    it {
      should_not contain_cassandra__opscenter__setting('hadoop base_job_tracker_proxy_port')
    }

    it {
      should_not contain_cassandra__opscenter__setting('ldap admin_group_name')
    }

    it {
      should_not contain_cassandra__opscenter__setting('ldap connection_timeout')
    }

    it {
      should_not contain_cassandra__opscenter__setting('ldap debug_ssl')
    }

    it {
      should_not contain_cassandra__opscenter__setting('ldap group_name_attribute')
    }

    it {
      should_not contain_cassandra__opscenter__setting('ldap group_search_base')
    }

    it {
      should_not contain_cassandra__opscenter__setting('ldap group_search_filter')
    }

    it {
      should_not contain_cassandra__opscenter__setting('ldap group_search_type')
    }

    it {
      should_not contain_cassandra__opscenter__setting('ldap ldap_security')
    }

    it {
      should_not contain_cassandra__opscenter__setting('ldap opt_referrals')
    }

    it {
      should_not contain_cassandra__opscenter__setting('ldap protocol_version')
    }

    it {
      should_not contain_cassandra__opscenter__setting('ldap search_dn')
    }

    it {
      should_not contain_cassandra__opscenter__setting('ldap search_password')
    }

    it {
      should_not contain_cassandra__opscenter__setting('ldap server_host')
    }

    it {
      should_not contain_cassandra__opscenter__setting('ldap server_port')
    }

    it {
      should_not contain_cassandra__opscenter__setting('ldap ssl_cacert')
    }

    it {
      should_not contain_cassandra__opscenter__setting('ldap ssl_cert')
    }

    it {
      should_not contain_cassandra__opscenter__setting('ldap ssl_key')
    }

    it {
      should_not contain_cassandra__opscenter__setting('ldap tls_demand')
    }

    it {
      should_not contain_cassandra__opscenter__setting('ldap tls_reqcert')
    }

    it {
      should_not contain_cassandra__opscenter__setting('ldap uri_scheme')
    }

    it {
      should_not contain_cassandra__opscenter__setting('ldap user_memberof_attribute')
    }

    it {
      should_not contain_cassandra__opscenter__setting('ldap user_search_base')
    }

    it {
      should_not contain_cassandra__opscenter__setting('ldap user_search_filter')
    }

    it {
      should_not contain_cassandra__opscenter__setting('logging level')
    }

    it {
      should_not contain_cassandra__opscenter__setting('logging log_length')
    }

    it {
      should_not contain_cassandra__opscenter__setting('logging log_path')
    }

    it {
      should_not contain_cassandra__opscenter__setting('logging max_rotate')
    }

    it {
      should_not contain_cassandra__opscenter__setting('logging resource_usage_interval')
    }

    it {
      should_not contain_cassandra__opscenter__setting('provisioning agent_install_timeout')
    }

    it {
      should_not contain_cassandra__opscenter__setting('provisioning keyspace_timeout')
    }

    it {
      should_not contain_cassandra__opscenter__setting('provisioning private_key_dir')
    }

    it {
      should_not contain_cassandra__opscenter__setting('repair_service alert_on_repair_failure')
    }

    it {
      should_not contain_cassandra__opscenter__setting('repair_service cluster_stabilization_period')
    }

    it {
      should_not contain_cassandra__opscenter__setting('repair_service error_logging_window')
    }

    it {
      should_not contain_cassandra__opscenter__setting('repair_service incremental_err_alert_threshold')
    }

    it {
      should_not contain_cassandra__opscenter__setting('repair_service incremental_range_repair')
    }

    it {
      should_not contain_cassandra__opscenter__setting('repair_service incremental_repair_tables')
    }

    it {
      should_not contain_cassandra__opscenter__setting('repair_service ks_update_period')
    }

    it {
      should_not contain_cassandra__opscenter__setting('repair_service log_directory')
    }

    it {
      should_not contain_cassandra__opscenter__setting('repair_service log_length')
    }

    it {
      should_not contain_cassandra__opscenter__setting('repair_service max_err_threshold')
    }

    it {
      should_not contain_cassandra__opscenter__setting('repair_service max_parallel_repairs')
    }

    it {
      should_not contain_cassandra__opscenter__setting('repair_service max_pending_repairs')
    }

    it {
      should_not contain_cassandra__opscenter__setting('repair_service max_rotate')
    }

    it {
      should_not contain_cassandra__opscenter__setting('repair_service min_repair_time')
    }

    it {
      should_not contain_cassandra__opscenter__setting('repair_service min_throughput')
    }

    it {
      should_not contain_cassandra__opscenter__setting('repair_service num_recent_throughputs')
    }

    it {
      should_not contain_cassandra__opscenter__setting('repair_service persist_directory')
    }

    it {
      should_not contain_cassandra__opscenter__setting('repair_service persist_period')
    }

    it {
      should_not contain_cassandra__opscenter__setting('repair_service restart_period')
    }

    it {
      should_not contain_cassandra__opscenter__setting('repair_service single_repair_timeout')
    }

    it {
      should_not contain_cassandra__opscenter__setting('repair_service single_task_err_threshold')
    }

    it {
      should_not contain_cassandra__opscenter__setting('repair_service snapshot_override')
    }

    it {
      should_not contain_cassandra__opscenter__setting('request_tracker queue_size')
    }

    it {
      should_not contain_cassandra__opscenter__setting('security config_encryption_active')
    }

    it {
      should_not contain_cassandra__opscenter__setting('security config_encryption_key_name')
    }

    it {
      should_not contain_cassandra__opscenter__setting('security config_encryption_key_path')
    }

    it {
      should_not contain_cassandra__opscenter__setting('spark base_master_proxy_port')
    }

    it {
      should_not contain_cassandra__opscenter__setting('stat_reporter initial_sleep')
    }

    it {
      should_not contain_cassandra__opscenter__setting('stat_reporter interval')
    }

    it {
      should_not contain_cassandra__opscenter__setting('stat_reporter report_file')
    }

    it {
      should_not contain_cassandra__opscenter__setting('stat_reporter ssl_key')
    }

    it {
      should_not contain_cassandra__opscenter__setting('ui default_api_timeout')
    }

    it {
      should_not contain_cassandra__opscenter__setting('ui max_metrics_requests')
    }

    it {
      should_not contain_cassandra__opscenter__setting('ui node_detail_refresh_delay')
    }

    it {
      should_not contain_cassandra__opscenter__setting('ui storagemap_ttl')
    }

    it {
      should_not contain_cassandra__opscenter__setting('webserver interface')
    }

    it {
      should_not contain_cassandra__opscenter__setting('webserver log_path')
    }

    it {
      should_not contain_cassandra__opscenter__setting('webserver port')
    }

    it {
      should_not contain_cassandra__opscenter__setting('webserver ssl_certfile')
    }

    it {
      should_not contain_cassandra__opscenter__setting('webserver ssl_keyfile')
    }

    it {
      should_not contain_cassandra__opscenter__setting('webserver ssl_port')
    }

    it {
      should_not contain_cassandra__opscenter__setting('webserver staticdir')
    }

    it {
      should_not contain_cassandra__opscenter__setting('webserver sub_process_timeout')
    }

    it {
      should_not contain_cassandra__opscenter__setting('webserver tarball_process_timeout')
    }

  end

  context 'Test that settings can be removed.' do
    let(:title) { 'section setting' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'not',
        :setting => 'wanted',
      }
    end

    it {
      should contain_ini_setting('not wanted').with({
        'ensure' => 'absent',
      })
    }
  end
end
