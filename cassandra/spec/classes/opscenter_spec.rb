require 'spec_helper'
describe 'cassandra::opscenter' do
  let(:pre_condition) { [
    'define ini_setting ($ensure = nil,
      $path,
      $section,
      $key_val_separator = nil,
      $setting,
      $value = nil) {}'
  ] }

  context 'Test params for cassandra::opscenter defaults.' do
    it {
      should contain_class('cassandra::opscenter').with({
        'authentication_enabled' => 'False',
        'ensure'                 => 'present',
        'config_file'            => '/etc/opscenter/opscenterd.conf',
        'package_name'           => 'opscenter',
        'service_enable'         => 'true',
        'service_ensure'         => 'running',
        'service_name'           => 'opscenterd',
        'webserver_interface'    => '0.0.0.0',
        'webserver_port'         => 8888,
      })
    }

    it { should have_resource_count(252) }

    it {
      should contain_cassandra__opscenter__setting('agents agent_certfile')
    }

    it {
      should contain_cassandra__opscenter__setting('agents agent_keyfile')
    }

    it {
      should contain_cassandra__opscenter__setting('agents agent_keyfile_raw')
    }

    it {
      should contain_cassandra__opscenter__setting('agents config_sleep')
    }

    it {
      should contain_cassandra__opscenter__setting('agents fingerprint_throttle')
    }

    it {
      should contain_cassandra__opscenter__setting('agents incoming_interface')
    }

    it {
      should contain_cassandra__opscenter__setting('agents incoming_port')
    }

    it {
      should contain_cassandra__opscenter__setting('agents install_throttle')
    }

    it {
      should contain_cassandra__opscenter__setting('agents not_seen_threshold')
    }

    it {
      should contain_cassandra__opscenter__setting('agents path_to_deb')
    }

    it {
      should contain_cassandra__opscenter__setting('agents path_to_find_java')
    }

    it {
      should contain_cassandra__opscenter__setting('agents path_to_installscript')
    }

    it {
      should contain_cassandra__opscenter__setting('agents path_to_rpm')
    }

    it {
      should contain_cassandra__opscenter__setting('agents path_to_sudowrap')
    }

    it {
      should contain_cassandra__opscenter__setting('agents reported_interface')
    }

    it {
      should contain_cassandra__opscenter__setting('agents runs_sudo')
    }

    it {
      should contain_cassandra__opscenter__setting('agents scp_executable')
    }

    it {
      should contain_cassandra__opscenter__setting('agents ssh_executable')
    }

    it {
      should contain_cassandra__opscenter__setting('agents ssh_keygen_executable')
    }

    it {
      should contain_cassandra__opscenter__setting('agents ssh_keyscan_executable')
    }

    it {
      should contain_cassandra__opscenter__setting('agents ssh_port')
    }

    it {
      should contain_cassandra__opscenter__setting('agents ssh_sys_known_hosts_file')
    }

    it {
      should contain_cassandra__opscenter__setting('agents ssh_user_known_hosts_file')
    }

    it {
      should contain_cassandra__opscenter__setting('agents ssl_certfile')
    }

    it {
      should contain_cassandra__opscenter__setting('agents ssl_keyfile')
    }

    it {
      should contain_cassandra__opscenter__setting('agents tmp_dir')
    }

    it {
      should contain_cassandra__opscenter__setting('agents use_ssl')
    }

    it {
      should contain_cassandra__opscenter__setting('authentication audit_auth')
    }

    it {
      should contain_cassandra__opscenter__setting('authentication audit_pattern')
    }

    it {
      should contain_cassandra__opscenter__setting('authentication authentication_method')
    }

    it {
      should contain_cassandra__opscenter__setting('authentication enabled')
    }

    it {
      should contain_cassandra__opscenter__setting('authentication passwd_db')
    }

    it {
      should contain_cassandra__opscenter__setting('authentication timeout')
    }

    it {
      should contain_cassandra__opscenter__setting('cloud accepted_certs')
    }

    it {
      should contain_cassandra__opscenter__setting('clusters add_cluster_timeout')
    }

    it {
      should contain_cassandra__opscenter__setting('clusters startup_sleep')
    }

    it {
      should contain_cassandra__opscenter__setting('definitions auto_update')
    }

    it {
      should contain_cassandra__opscenter__setting('definitions definitions_dir')
    }

    it {
      should contain_cassandra__opscenter__setting('definitions download_filename')
    }

    it {
      should contain_cassandra__opscenter__setting('definitions download_host')
    }

    it {
      should contain_cassandra__opscenter__setting('definitions download_port')
    }

    it {
      should contain_cassandra__opscenter__setting('definitions hash_filename')
    }

    it {
      should contain_cassandra__opscenter__setting('definitions sleep')
    }

    it {
      should contain_cassandra__opscenter__setting('definitions ssl_certfile')
    }

    it {
      should contain_cassandra__opscenter__setting('definitions use_ssl')
    }

    it {
      should contain_cassandra__opscenter__setting('failover failover_configuration_directory')
    }

    it {
      should contain_cassandra__opscenter__setting('failover heartbeat_fail_window')
    }

    it {
      should contain_cassandra__opscenter__setting('failover heartbeat_period')
    }

    it {
      should contain_cassandra__opscenter__setting('failover heartbeat_reply_period')
    }

    it {
      should contain_cassandra__opscenter__setting('hadoop base_job_tracker_proxy_port')
    }

    it {
      should contain_cassandra__opscenter__setting('ldap admin_group_name')
    }

    it {
      should contain_cassandra__opscenter__setting('ldap connection_timeout')
    }

    it {
      should contain_cassandra__opscenter__setting('ldap debug_ssl')
    }

    it {
      should contain_cassandra__opscenter__setting('ldap group_name_attribute')
    }

    it {
      should contain_cassandra__opscenter__setting('ldap group_search_base')
    }

    it {
      should contain_cassandra__opscenter__setting('ldap group_search_filter')
    }

    it {
      should contain_cassandra__opscenter__setting('ldap group_search_type')
    }

    it {
      should contain_cassandra__opscenter__setting('ldap ldap_security')
    }

    it {
      should contain_cassandra__opscenter__setting('ldap opt_referrals')
    }

    it {
      should contain_cassandra__opscenter__setting('ldap protocol_version')
    }

    it {
      should contain_cassandra__opscenter__setting('ldap search_dn')
    }

    it {
      should contain_cassandra__opscenter__setting('ldap search_password')
    }

    it {
      should contain_cassandra__opscenter__setting('ldap server_host')
    }

    it {
      should contain_cassandra__opscenter__setting('ldap server_port')
    }

    it {
      should contain_cassandra__opscenter__setting('ldap ssl_cacert')
    }

    it {
      should contain_cassandra__opscenter__setting('ldap ssl_cert')
    }

    it {
      should contain_cassandra__opscenter__setting('ldap ssl_key')
    }

    it {
      should contain_cassandra__opscenter__setting('ldap tls_demand')
    }

    it {
      should contain_cassandra__opscenter__setting('ldap tls_reqcert')
    }

    it {
      should contain_cassandra__opscenter__setting('ldap uri_scheme')
    }

    it {
      should contain_cassandra__opscenter__setting('ldap user_memberof_attribute')
    }

    it {
      should contain_cassandra__opscenter__setting('ldap user_search_base')
    }

    it {
      should contain_cassandra__opscenter__setting('ldap user_search_filter')
    }

    it {
      should contain_cassandra__opscenter__setting('logging level')
    }

    it {
      should contain_cassandra__opscenter__setting('logging log_length')
    }

    it {
      should contain_cassandra__opscenter__setting('logging log_path')
    }

    it {
      should contain_cassandra__opscenter__setting('logging max_rotate')
    }

    it {
      should contain_cassandra__opscenter__setting('logging resource_usage_interval')
    }

    it {
      should contain_cassandra__opscenter__setting('provisioning agent_install_timeout')
    }

    it {
      should contain_cassandra__opscenter__setting('provisioning keyspace_timeout')
    }

    it {
      should contain_cassandra__opscenter__setting('provisioning private_key_dir')
    }

    it {
      should contain_cassandra__opscenter__setting('repair_service alert_on_repair_failure')
    }

    it {
      should contain_cassandra__opscenter__setting('repair_service cluster_stabilization_period')
    }

    it {
      should contain_cassandra__opscenter__setting('repair_service error_logging_window')
    }

    it {
      should contain_cassandra__opscenter__setting('repair_service incremental_err_alert_threshold')
    }

    it {
      should contain_cassandra__opscenter__setting('repair_service incremental_range_repair')
    }

    it {
      should contain_cassandra__opscenter__setting('repair_service incremental_repair_tables')
    }

    it {
      should contain_cassandra__opscenter__setting('repair_service ks_update_period')
    }

    it {
      should contain_cassandra__opscenter__setting('repair_service log_directory')
    }

    it {
      should contain_cassandra__opscenter__setting('repair_service log_length')
    }

    it {
      should contain_cassandra__opscenter__setting('repair_service max_err_threshold')
    }

    it {
      should contain_cassandra__opscenter__setting('repair_service max_parallel_repairs')
    }

    it {
      should contain_cassandra__opscenter__setting('repair_service max_pending_repairs')
    }

    it {
      should contain_cassandra__opscenter__setting('repair_service max_rotate')
    }

    it {
      should contain_cassandra__opscenter__setting('repair_service min_repair_time')
    }

    it {
      should contain_cassandra__opscenter__setting('repair_service min_throughput')
    }

    it {
      should contain_cassandra__opscenter__setting('repair_service num_recent_throughputs')
    }

    it {
      should contain_cassandra__opscenter__setting('repair_service persist_directory')
    }

    it {
      should contain_cassandra__opscenter__setting('repair_service persist_period')
    }

    it {
      should contain_cassandra__opscenter__setting('repair_service restart_period')
    }

    it {
      should contain_cassandra__opscenter__setting('repair_service single_repair_timeout')
    }

    it {
      should contain_cassandra__opscenter__setting('repair_service single_task_err_threshold')
    }

    it {
      should contain_cassandra__opscenter__setting('repair_service snapshot_override')
    }

    it {
      should contain_cassandra__opscenter__setting('request_tracker queue_size')
    }

    it {
      should contain_cassandra__opscenter__setting('security config_encryption_active')
    }

    it {
      should contain_cassandra__opscenter__setting('security config_encryption_key_name')
    }

    it {
      should contain_cassandra__opscenter__setting('security config_encryption_key_path')
    }

    it {
      should contain_cassandra__opscenter__setting('spark base_master_proxy_port')
    }

    it {
      should contain_cassandra__opscenter__setting('stat_reporter initial_sleep')
    }

    it {
      should contain_cassandra__opscenter__setting('stat_reporter interval')
    }

    it {
      should contain_cassandra__opscenter__setting('stat_reporter report_file')
    }

    it {
      should contain_cassandra__opscenter__setting('stat_reporter ssl_key')
    }

    it {
      should contain_cassandra__opscenter__setting('ui default_api_timeout')
    }

    it {
      should contain_cassandra__opscenter__setting('ui max_metrics_requests')
    }

    it {
      should contain_cassandra__opscenter__setting('ui node_detail_refresh_delay')
    }

    it {
      should contain_cassandra__opscenter__setting('ui storagemap_ttl')
    }

    it {
      should contain_cassandra__opscenter__setting('webserver interface')
    }

    it {
      should contain_cassandra__opscenter__setting('webserver log_path')
    }

    it {
      should contain_cassandra__opscenter__setting('webserver port')
    }

    it {
      should contain_cassandra__opscenter__setting('webserver ssl_certfile')
    }

    it {
      should contain_cassandra__opscenter__setting('webserver ssl_keyfile')
    }

    it {
      should contain_cassandra__opscenter__setting('webserver ssl_port')
    }

    it {
      should contain_cassandra__opscenter__setting('webserver staticdir')
    }

    it {
      should contain_cassandra__opscenter__setting('webserver sub_process_timeout')
    }

    it {
      should contain_cassandra__opscenter__setting('webserver tarball_process_timeout')
    }

  end

  context 'Test params for cassandra::opscenter special cases.' do
    let :params do
      {
        :authentication_method            => 42,
        :failover_configuration_directory => '/path/to',
      }
    end

    it {
      should contain_class('cassandra::opscenter').with({
        'authentication_method'            => 42,
        'failover_configuration_directory' => '/path/to',
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
