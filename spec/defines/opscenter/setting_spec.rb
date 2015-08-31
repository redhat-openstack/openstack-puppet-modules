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

  context 'agents agent_certfile' do
    let(:title) { 'agents agent_certfile' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'agents',
        :setting => 'agent_certfile',
      }
    end

    it {
      should contain_ini_setting('agents agent_certfile').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'agents',
        'setting' => 'agent_certfile',
      })
    }
  end

  context 'agents agent_keyfile' do
    let(:title) { 'agents agent_keyfile' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'agents',
        :setting => 'agent_keyfile',
      }
    end

    it {
      should contain_ini_setting('agents agent_keyfile').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'agents',
        'setting' => 'agent_keyfile',
      })
    }
  end

  context 'agents agent_keyfile_raw' do
    let(:title) { 'agents agent_keyfile_raw' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'agents',
        :setting => 'agent_keyfile_raw',
      }
    end

    it {
      should contain_ini_setting('agents agent_keyfile_raw').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'agents',
        'setting' => 'agent_keyfile_raw',
      })
    }
  end

  context 'agents config_sleep' do
    let(:title) { 'agents config_sleep' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'agents',
        :setting => 'config_sleep',
      }
    end

    it {
      should contain_ini_setting('agents config_sleep').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'agents',
        'setting' => 'config_sleep',
      })
    }
  end

  context 'agents fingerprint_throttle' do
    let(:title) { 'agents fingerprint_throttle' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'agents',
        :setting => 'fingerprint_throttle',
      }
    end

    it {
      should contain_ini_setting('agents fingerprint_throttle').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'agents',
        'setting' => 'fingerprint_throttle',
      })
    }
  end

  context 'agents incoming_interface' do
    let(:title) { 'agents incoming_interface' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'agents',
        :setting => 'incoming_interface',
      }
    end

    it {
      should contain_ini_setting('agents incoming_interface').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'agents',
        'setting' => 'incoming_interface',
      })
    }
  end

  context 'agents incoming_port' do
    let(:title) { 'agents incoming_port' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'agents',
        :setting => 'incoming_port',
      }
    end

    it {
      should contain_ini_setting('agents incoming_port').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'agents',
        'setting' => 'incoming_port',
      })
    }
  end

  context 'agents install_throttle' do
    let(:title) { 'agents install_throttle' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'agents',
        :setting => 'install_throttle',
      }
    end

    it {
      should contain_ini_setting('agents install_throttle').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'agents',
        'setting' => 'install_throttle',
      })
    }
  end

  context 'agents not_seen_threshold' do
    let(:title) { 'agents not_seen_threshold' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'agents',
        :setting => 'not_seen_threshold',
      }
    end

    it {
      should contain_ini_setting('agents not_seen_threshold').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'agents',
        'setting' => 'not_seen_threshold',
      })
    }
  end

  context 'agents path_to_deb' do
    let(:title) { 'agents path_to_deb' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'agents',
        :setting => 'path_to_deb',
      }
    end

    it {
      should contain_ini_setting('agents path_to_deb').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'agents',
        'setting' => 'path_to_deb',
      })
    }
  end

  context 'agents path_to_find_java' do
    let(:title) { 'agents path_to_find_java' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'agents',
        :setting => 'path_to_find_java',
      }
    end

    it {
      should contain_ini_setting('agents path_to_find_java').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'agents',
        'setting' => 'path_to_find_java',
      })
    }
  end

  context 'agents path_to_installscript' do
    let(:title) { 'agents path_to_installscript' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'agents',
        :setting => 'path_to_installscript',
      }
    end

    it {
      should contain_ini_setting('agents path_to_installscript').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'agents',
        'setting' => 'path_to_installscript',
      })
    }
  end

  context 'agents path_to_rpm' do
    let(:title) { 'agents path_to_rpm' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'agents',
        :setting => 'path_to_rpm',
      }
    end

    it {
      should contain_ini_setting('agents path_to_rpm').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'agents',
        'setting' => 'path_to_rpm',
      })
    }
  end

  context 'agents path_to_sudowrap' do
    let(:title) { 'agents path_to_sudowrap' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'agents',
        :setting => 'path_to_sudowrap',
      }
    end

    it {
      should contain_ini_setting('agents path_to_sudowrap').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'agents',
        'setting' => 'path_to_sudowrap',
      })
    }
  end

  context 'agents reported_interface' do
    let(:title) { 'agents reported_interface' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'agents',
        :setting => 'reported_interface',
      }
    end

    it {
      should contain_ini_setting('agents reported_interface').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'agents',
        'setting' => 'reported_interface',
      })
    }
  end

  context 'agents runs_sudo' do
    let(:title) { 'agents runs_sudo' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'agents',
        :setting => 'runs_sudo',
      }
    end

    it {
      should contain_ini_setting('agents runs_sudo').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'agents',
        'setting' => 'runs_sudo',
      })
    }
  end

  context 'agents scp_executable' do
    let(:title) { 'agents scp_executable' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'agents',
        :setting => 'scp_executable',
      }
    end

    it {
      should contain_ini_setting('agents scp_executable').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'agents',
        'setting' => 'scp_executable',
      })
    }
  end

  context 'agents ssh_executable' do
    let(:title) { 'agents ssh_executable' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'agents',
        :setting => 'ssh_executable',
      }
    end

    it {
      should contain_ini_setting('agents ssh_executable').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'agents',
        'setting' => 'ssh_executable',
      })
    }
  end

  context 'agents ssh_keygen_executable' do
    let(:title) { 'agents ssh_keygen_executable' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'agents',
        :setting => 'ssh_keygen_executable',
      }
    end

    it {
      should contain_ini_setting('agents ssh_keygen_executable').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'agents',
        'setting' => 'ssh_keygen_executable',
      })
    }
  end

  context 'agents ssh_keyscan_executable' do
    let(:title) { 'agents ssh_keyscan_executable' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'agents',
        :setting => 'ssh_keyscan_executable',
      }
    end

    it {
      should contain_ini_setting('agents ssh_keyscan_executable').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'agents',
        'setting' => 'ssh_keyscan_executable',
      })
    }
  end

  context 'agents ssh_port' do
    let(:title) { 'agents ssh_port' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'agents',
        :setting => 'ssh_port',
      }
    end

    it {
      should contain_ini_setting('agents ssh_port').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'agents',
        'setting' => 'ssh_port',
      })
    }
  end

  context 'agents ssh_sys_known_hosts_file' do
    let(:title) { 'agents ssh_sys_known_hosts_file' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'agents',
        :setting => 'ssh_sys_known_hosts_file',
      }
    end

    it {
      should contain_ini_setting('agents ssh_sys_known_hosts_file').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'agents',
        'setting' => 'ssh_sys_known_hosts_file',
      })
    }
  end

  context 'agents ssh_user_known_hosts_file' do
    let(:title) { 'agents ssh_user_known_hosts_file' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'agents',
        :setting => 'ssh_user_known_hosts_file',
      }
    end

    it {
      should contain_ini_setting('agents ssh_user_known_hosts_file').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'agents',
        'setting' => 'ssh_user_known_hosts_file',
      })
    }
  end

  context 'agents ssl_certfile' do
    let(:title) { 'agents ssl_certfile' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'agents',
        :setting => 'ssl_certfile',
      }
    end

    it {
      should contain_ini_setting('agents ssl_certfile').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'agents',
        'setting' => 'ssl_certfile',
      })
    }
  end

  context 'agents ssl_keyfile' do
    let(:title) { 'agents ssl_keyfile' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'agents',
        :setting => 'ssl_keyfile',
      }
    end

    it {
      should contain_ini_setting('agents ssl_keyfile').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'agents',
        'setting' => 'ssl_keyfile',
      })
    }
  end

  context 'agents tmp_dir' do
    let(:title) { 'agents tmp_dir' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'agents',
        :setting => 'tmp_dir',
      }
    end

    it {
      should contain_ini_setting('agents tmp_dir').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'agents',
        'setting' => 'tmp_dir',
      })
    }
  end

  context 'agents use_ssl' do
    let(:title) { 'agents use_ssl' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'agents',
        :setting => 'use_ssl',
      }
    end

    it {
      should contain_ini_setting('agents use_ssl').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'agents',
        'setting' => 'use_ssl',
      })
    }
  end

  context 'authentication audit_auth' do
    let(:title) { 'authentication audit_auth' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'authentication',
        :setting => 'audit_auth',
      }
    end

    it {
      should contain_ini_setting('authentication audit_auth').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'authentication',
        'setting' => 'audit_auth',
      })
    }
  end

  context 'authentication audit_pattern' do
    let(:title) { 'authentication audit_pattern' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'authentication',
        :setting => 'audit_pattern',
      }
    end

    it {
      should contain_ini_setting('authentication audit_pattern').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'authentication',
        'setting' => 'audit_pattern',
      })
    }
  end

  context 'authentication authentication_method' do
    let(:title) { 'authentication authentication_method' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'authentication',
        :setting => 'authentication_method',
      }
    end

    it {
      should contain_ini_setting('authentication authentication_method').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'authentication',
        'setting' => 'authentication_method',
      })
    }
  end

  context 'authentication enabled' do
    let(:title) { 'authentication enabled' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'authentication',
        :setting => 'enabled',
      }
    end

    it {
      should contain_ini_setting('authentication enabled').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'authentication',
        'setting' => 'enabled',
      })
    }
  end

  context 'authentication passwd_db' do
    let(:title) { 'authentication passwd_db' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'authentication',
        :setting => 'passwd_db',
      }
    end

    it {
      should contain_ini_setting('authentication passwd_db').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'authentication',
        'setting' => 'passwd_db',
      })
    }
  end

  context 'authentication timeout' do
    let(:title) { 'authentication timeout' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'authentication',
        :setting => 'timeout',
      }
    end

    it {
      should contain_ini_setting('authentication timeout').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'authentication',
        'setting' => 'timeout',
      })
    }
  end

  context 'cloud accepted_certs' do
    let(:title) { 'cloud accepted_certs' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'cloud',
        :setting => 'accepted_certs',
      }
    end

    it {
      should contain_ini_setting('cloud accepted_certs').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'cloud',
        'setting' => 'accepted_certs',
      })
    }
  end

  context 'clusters add_cluster_timeout' do
    let(:title) { 'clusters add_cluster_timeout' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'clusters',
        :setting => 'add_cluster_timeout',
      }
    end

    it {
      should contain_ini_setting('clusters add_cluster_timeout').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'clusters',
        'setting' => 'add_cluster_timeout',
      })
    }
  end

  context 'clusters startup_sleep' do
    let(:title) { 'clusters startup_sleep' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'clusters',
        :setting => 'startup_sleep',
      }
    end

    it {
      should contain_ini_setting('clusters startup_sleep').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'clusters',
        'setting' => 'startup_sleep',
      })
    }
  end

  context 'definitions auto_update' do
    let(:title) { 'definitions auto_update' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'definitions',
        :setting => 'auto_update',
      }
    end

    it {
      should contain_ini_setting('definitions auto_update').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'definitions',
        'setting' => 'auto_update',
      })
    }
  end

  context 'definitions definitions_dir' do
    let(:title) { 'definitions definitions_dir' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'definitions',
        :setting => 'definitions_dir',
      }
    end

    it {
      should contain_ini_setting('definitions definitions_dir').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'definitions',
        'setting' => 'definitions_dir',
      })
    }
  end

  context 'definitions download_filename' do
    let(:title) { 'definitions download_filename' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'definitions',
        :setting => 'download_filename',
      }
    end

    it {
      should contain_ini_setting('definitions download_filename').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'definitions',
        'setting' => 'download_filename',
      })
    }
  end

  context 'definitions download_host' do
    let(:title) { 'definitions download_host' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'definitions',
        :setting => 'download_host',
      }
    end

    it {
      should contain_ini_setting('definitions download_host').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'definitions',
        'setting' => 'download_host',
      })
    }
  end

  context 'definitions download_port' do
    let(:title) { 'definitions download_port' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'definitions',
        :setting => 'download_port',
      }
    end

    it {
      should contain_ini_setting('definitions download_port').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'definitions',
        'setting' => 'download_port',
      })
    }
  end

  context 'definitions hash_filename' do
    let(:title) { 'definitions hash_filename' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'definitions',
        :setting => 'hash_filename',
      }
    end

    it {
      should contain_ini_setting('definitions hash_filename').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'definitions',
        'setting' => 'hash_filename',
      })
    }
  end

  context 'definitions sleep' do
    let(:title) { 'definitions sleep' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'definitions',
        :setting => 'sleep',
      }
    end

    it {
      should contain_ini_setting('definitions sleep').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'definitions',
        'setting' => 'sleep',
      })
    }
  end

  context 'definitions ssl_certfile' do
    let(:title) { 'definitions ssl_certfile' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'definitions',
        :setting => 'ssl_certfile',
      }
    end

    it {
      should contain_ini_setting('definitions ssl_certfile').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'definitions',
        'setting' => 'ssl_certfile',
      })
    }
  end

  context 'definitions use_ssl' do
    let(:title) { 'definitions use_ssl' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'definitions',
        :setting => 'use_ssl',
      }
    end

    it {
      should contain_ini_setting('definitions use_ssl').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'definitions',
        'setting' => 'use_ssl',
      })
    }
  end

  context 'failover failover_configuration_directory' do
    let(:title) { 'failover failover_configuration_directory' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'failover',
        :setting => 'failover_configuration_directory',
      }
    end

    it {
      should contain_ini_setting('failover failover_configuration_directory').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'failover',
        'setting' => 'failover_configuration_directory',
      })
    }
  end

  context 'failover heartbeat_fail_window' do
    let(:title) { 'failover heartbeat_fail_window' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'failover',
        :setting => 'heartbeat_fail_window',
      }
    end

    it {
      should contain_ini_setting('failover heartbeat_fail_window').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'failover',
        'setting' => 'heartbeat_fail_window',
      })
    }
  end

  context 'failover heartbeat_period' do
    let(:title) { 'failover heartbeat_period' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'failover',
        :setting => 'heartbeat_period',
      }
    end

    it {
      should contain_ini_setting('failover heartbeat_period').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'failover',
        'setting' => 'heartbeat_period',
      })
    }
  end

  context 'failover heartbeat_reply_period' do
    let(:title) { 'failover heartbeat_reply_period' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'failover',
        :setting => 'heartbeat_reply_period',
      }
    end

    it {
      should contain_ini_setting('failover heartbeat_reply_period').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'failover',
        'setting' => 'heartbeat_reply_period',
      })
    }
  end

  context 'hadoop base_job_tracker_proxy_port' do
    let(:title) { 'hadoop base_job_tracker_proxy_port' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'hadoop',
        :setting => 'base_job_tracker_proxy_port',
      }
    end

    it {
      should contain_ini_setting('hadoop base_job_tracker_proxy_port').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'hadoop',
        'setting' => 'base_job_tracker_proxy_port',
      })
    }
  end

  context 'ldap admin_group_name' do
    let(:title) { 'ldap admin_group_name' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'ldap',
        :setting => 'admin_group_name',
      }
    end

    it {
      should contain_ini_setting('ldap admin_group_name').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'ldap',
        'setting' => 'admin_group_name',
      })
    }
  end

  context 'ldap connection_timeout' do
    let(:title) { 'ldap connection_timeout' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'ldap',
        :setting => 'connection_timeout',
      }
    end

    it {
      should contain_ini_setting('ldap connection_timeout').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'ldap',
        'setting' => 'connection_timeout',
      })
    }
  end

  context 'ldap debug_ssl' do
    let(:title) { 'ldap debug_ssl' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'ldap',
        :setting => 'debug_ssl',
      }
    end

    it {
      should contain_ini_setting('ldap debug_ssl').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'ldap',
        'setting' => 'debug_ssl',
      })
    }
  end

  context 'ldap group_name_attribute' do
    let(:title) { 'ldap group_name_attribute' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'ldap',
        :setting => 'group_name_attribute',
      }
    end

    it {
      should contain_ini_setting('ldap group_name_attribute').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'ldap',
        'setting' => 'group_name_attribute',
      })
    }
  end

  context 'ldap group_search_base' do
    let(:title) { 'ldap group_search_base' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'ldap',
        :setting => 'group_search_base',
      }
    end

    it {
      should contain_ini_setting('ldap group_search_base').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'ldap',
        'setting' => 'group_search_base',
      })
    }
  end

  context 'ldap group_search_filter' do
    let(:title) { 'ldap group_search_filter' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'ldap',
        :setting => 'group_search_filter',
      }
    end

    it {
      should contain_ini_setting('ldap group_search_filter').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'ldap',
        'setting' => 'group_search_filter',
      })
    }
  end

  context 'ldap group_search_type' do
    let(:title) { 'ldap group_search_type' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'ldap',
        :setting => 'group_search_type',
      }
    end

    it {
      should contain_ini_setting('ldap group_search_type').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'ldap',
        'setting' => 'group_search_type',
      })
    }
  end

  context 'ldap ldap_security' do
    let(:title) { 'ldap ldap_security' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'ldap',
        :setting => 'ldap_security',
      }
    end

    it {
      should contain_ini_setting('ldap ldap_security').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'ldap',
        'setting' => 'ldap_security',
      })
    }
  end

  context 'ldap opt_referrals' do
    let(:title) { 'ldap opt_referrals' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'ldap',
        :setting => 'opt_referrals',
      }
    end

    it {
      should contain_ini_setting('ldap opt_referrals').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'ldap',
        'setting' => 'opt_referrals',
      })
    }
  end

  context 'ldap protocol_version' do
    let(:title) { 'ldap protocol_version' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'ldap',
        :setting => 'protocol_version',
      }
    end

    it {
      should contain_ini_setting('ldap protocol_version').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'ldap',
        'setting' => 'protocol_version',
      })
    }
  end

  context 'ldap search_dn' do
    let(:title) { 'ldap search_dn' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'ldap',
        :setting => 'search_dn',
      }
    end

    it {
      should contain_ini_setting('ldap search_dn').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'ldap',
        'setting' => 'search_dn',
      })
    }
  end

  context 'ldap search_password' do
    let(:title) { 'ldap search_password' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'ldap',
        :setting => 'search_password',
      }
    end

    it {
      should contain_ini_setting('ldap search_password').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'ldap',
        'setting' => 'search_password',
      })
    }
  end

  context 'ldap server_host' do
    let(:title) { 'ldap server_host' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'ldap',
        :setting => 'server_host',
      }
    end

    it {
      should contain_ini_setting('ldap server_host').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'ldap',
        'setting' => 'server_host',
      })
    }
  end

  context 'ldap server_port' do
    let(:title) { 'ldap server_port' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'ldap',
        :setting => 'server_port',
      }
    end

    it {
      should contain_ini_setting('ldap server_port').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'ldap',
        'setting' => 'server_port',
      })
    }
  end

  context 'ldap ssl_cacert' do
    let(:title) { 'ldap ssl_cacert' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'ldap',
        :setting => 'ssl_cacert',
      }
    end

    it {
      should contain_ini_setting('ldap ssl_cacert').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'ldap',
        'setting' => 'ssl_cacert',
      })
    }
  end

  context 'ldap ssl_cert' do
    let(:title) { 'ldap ssl_cert' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'ldap',
        :setting => 'ssl_cert',
      }
    end

    it {
      should contain_ini_setting('ldap ssl_cert').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'ldap',
        'setting' => 'ssl_cert',
      })
    }
  end

  context 'ldap ssl_key' do
    let(:title) { 'ldap ssl_key' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'ldap',
        :setting => 'ssl_key',
      }
    end

    it {
      should contain_ini_setting('ldap ssl_key').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'ldap',
        'setting' => 'ssl_key',
      })
    }
  end

  context 'ldap tls_demand' do
    let(:title) { 'ldap tls_demand' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'ldap',
        :setting => 'tls_demand',
      }
    end

    it {
      should contain_ini_setting('ldap tls_demand').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'ldap',
        'setting' => 'tls_demand',
      })
    }
  end

  context 'ldap tls_reqcert' do
    let(:title) { 'ldap tls_reqcert' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'ldap',
        :setting => 'tls_reqcert',
      }
    end

    it {
      should contain_ini_setting('ldap tls_reqcert').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'ldap',
        'setting' => 'tls_reqcert',
      })
    }
  end

  context 'ldap uri_scheme' do
    let(:title) { 'ldap uri_scheme' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'ldap',
        :setting => 'uri_scheme',
      }
    end

    it {
      should contain_ini_setting('ldap uri_scheme').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'ldap',
        'setting' => 'uri_scheme',
      })
    }
  end

  context 'ldap user_memberof_attribute' do
    let(:title) { 'ldap user_memberof_attribute' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'ldap',
        :setting => 'user_memberof_attribute',
      }
    end

    it {
      should contain_ini_setting('ldap user_memberof_attribute').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'ldap',
        'setting' => 'user_memberof_attribute',
      })
    }
  end

  context 'ldap user_search_base' do
    let(:title) { 'ldap user_search_base' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'ldap',
        :setting => 'user_search_base',
      }
    end

    it {
      should contain_ini_setting('ldap user_search_base').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'ldap',
        'setting' => 'user_search_base',
      })
    }
  end

  context 'ldap user_search_filter' do
    let(:title) { 'ldap user_search_filter' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'ldap',
        :setting => 'user_search_filter',
      }
    end

    it {
      should contain_ini_setting('ldap user_search_filter').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'ldap',
        'setting' => 'user_search_filter',
      })
    }
  end

  context 'logging level' do
    let(:title) { 'logging level' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'logging',
        :setting => 'level',
      }
    end

    it {
      should contain_ini_setting('logging level').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'logging',
        'setting' => 'level',
      })
    }
  end

  context 'logging log_length' do
    let(:title) { 'logging log_length' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'logging',
        :setting => 'log_length',
      }
    end

    it {
      should contain_ini_setting('logging log_length').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'logging',
        'setting' => 'log_length',
      })
    }
  end

  context 'logging log_path' do
    let(:title) { 'logging log_path' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'logging',
        :setting => 'log_path',
      }
    end

    it {
      should contain_ini_setting('logging log_path').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'logging',
        'setting' => 'log_path',
      })
    }
  end

  context 'logging max_rotate' do
    let(:title) { 'logging max_rotate' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'logging',
        :setting => 'max_rotate',
      }
    end

    it {
      should contain_ini_setting('logging max_rotate').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'logging',
        'setting' => 'max_rotate',
      })
    }
  end

  context 'logging resource_usage_interval' do
    let(:title) { 'logging resource_usage_interval' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'logging',
        :setting => 'resource_usage_interval',
      }
    end

    it {
      should contain_ini_setting('logging resource_usage_interval').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'logging',
        'setting' => 'resource_usage_interval',
      })
    }
  end

  context 'provisioning agent_install_timeout' do
    let(:title) { 'provisioning agent_install_timeout' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'provisioning',
        :setting => 'agent_install_timeout',
      }
    end

    it {
      should contain_ini_setting('provisioning agent_install_timeout').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'provisioning',
        'setting' => 'agent_install_timeout',
      })
    }
  end

  context 'provisioning keyspace_timeout' do
    let(:title) { 'provisioning keyspace_timeout' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'provisioning',
        :setting => 'keyspace_timeout',
      }
    end

    it {
      should contain_ini_setting('provisioning keyspace_timeout').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'provisioning',
        'setting' => 'keyspace_timeout',
      })
    }
  end

  context 'provisioning private_key_dir' do
    let(:title) { 'provisioning private_key_dir' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'provisioning',
        :setting => 'private_key_dir',
      }
    end

    it {
      should contain_ini_setting('provisioning private_key_dir').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'provisioning',
        'setting' => 'private_key_dir',
      })
    }
  end

  context 'repair_service alert_on_repair_failure' do
    let(:title) { 'repair_service alert_on_repair_failure' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'repair_service',
        :setting => 'alert_on_repair_failure',
      }
    end

    it {
      should contain_ini_setting('repair_service alert_on_repair_failure').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'repair_service',
        'setting' => 'alert_on_repair_failure',
      })
    }
  end

  context 'repair_service cluster_stabilization_period' do
    let(:title) { 'repair_service cluster_stabilization_period' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'repair_service',
        :setting => 'cluster_stabilization_period',
      }
    end

    it {
      should contain_ini_setting('repair_service cluster_stabilization_period').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'repair_service',
        'setting' => 'cluster_stabilization_period',
      })
    }
  end

  context 'repair_service error_logging_window' do
    let(:title) { 'repair_service error_logging_window' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'repair_service',
        :setting => 'error_logging_window',
      }
    end

    it {
      should contain_ini_setting('repair_service error_logging_window').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'repair_service',
        'setting' => 'error_logging_window',
      })
    }
  end

  context 'repair_service incremental_err_alert_threshold' do
    let(:title) { 'repair_service incremental_err_alert_threshold' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'repair_service',
        :setting => 'incremental_err_alert_threshold',
      }
    end

    it {
      should contain_ini_setting('repair_service incremental_err_alert_threshold').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'repair_service',
        'setting' => 'incremental_err_alert_threshold',
      })
    }
  end

  context 'repair_service incremental_range_repair' do
    let(:title) { 'repair_service incremental_range_repair' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'repair_service',
        :setting => 'incremental_range_repair',
      }
    end

    it {
      should contain_ini_setting('repair_service incremental_range_repair').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'repair_service',
        'setting' => 'incremental_range_repair',
      })
    }
  end

  context 'repair_service incremental_repair_tables' do
    let(:title) { 'repair_service incremental_repair_tables' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'repair_service',
        :setting => 'incremental_repair_tables',
      }
    end

    it {
      should contain_ini_setting('repair_service incremental_repair_tables').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'repair_service',
        'setting' => 'incremental_repair_tables',
      })
    }
  end

  context 'repair_service ks_update_period' do
    let(:title) { 'repair_service ks_update_period' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'repair_service',
        :setting => 'ks_update_period',
      }
    end

    it {
      should contain_ini_setting('repair_service ks_update_period').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'repair_service',
        'setting' => 'ks_update_period',
      })
    }
  end

  context 'repair_service log_directory' do
    let(:title) { 'repair_service log_directory' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'repair_service',
        :setting => 'log_directory',
      }
    end

    it {
      should contain_ini_setting('repair_service log_directory').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'repair_service',
        'setting' => 'log_directory',
      })
    }
  end

  context 'repair_service log_length' do
    let(:title) { 'repair_service log_length' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'repair_service',
        :setting => 'log_length',
      }
    end

    it {
      should contain_ini_setting('repair_service log_length').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'repair_service',
        'setting' => 'log_length',
      })
    }
  end

  context 'repair_service max_err_threshold' do
    let(:title) { 'repair_service max_err_threshold' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'repair_service',
        :setting => 'max_err_threshold',
      }
    end

    it {
      should contain_ini_setting('repair_service max_err_threshold').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'repair_service',
        'setting' => 'max_err_threshold',
      })
    }
  end

  context 'repair_service max_parallel_repairs' do
    let(:title) { 'repair_service max_parallel_repairs' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'repair_service',
        :setting => 'max_parallel_repairs',
      }
    end

    it {
      should contain_ini_setting('repair_service max_parallel_repairs').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'repair_service',
        'setting' => 'max_parallel_repairs',
      })
    }
  end

  context 'repair_service max_pending_repairs' do
    let(:title) { 'repair_service max_pending_repairs' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'repair_service',
        :setting => 'max_pending_repairs',
      }
    end

    it {
      should contain_ini_setting('repair_service max_pending_repairs').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'repair_service',
        'setting' => 'max_pending_repairs',
      })
    }
  end

  context 'repair_service max_rotate' do
    let(:title) { 'repair_service max_rotate' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'repair_service',
        :setting => 'max_rotate',
      }
    end

    it {
      should contain_ini_setting('repair_service max_rotate').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'repair_service',
        'setting' => 'max_rotate',
      })
    }
  end

  context 'repair_service min_repair_time' do
    let(:title) { 'repair_service min_repair_time' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'repair_service',
        :setting => 'min_repair_time',
      }
    end

    it {
      should contain_ini_setting('repair_service min_repair_time').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'repair_service',
        'setting' => 'min_repair_time',
      })
    }
  end

  context 'repair_service min_throughput' do
    let(:title) { 'repair_service min_throughput' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'repair_service',
        :setting => 'min_throughput',
      }
    end

    it {
      should contain_ini_setting('repair_service min_throughput').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'repair_service',
        'setting' => 'min_throughput',
      })
    }
  end

  context 'repair_service num_recent_throughputs' do
    let(:title) { 'repair_service num_recent_throughputs' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'repair_service',
        :setting => 'num_recent_throughputs',
      }
    end

    it {
      should contain_ini_setting('repair_service num_recent_throughputs').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'repair_service',
        'setting' => 'num_recent_throughputs',
      })
    }
  end

  context 'repair_service persist_directory' do
    let(:title) { 'repair_service persist_directory' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'repair_service',
        :setting => 'persist_directory',
      }
    end

    it {
      should contain_ini_setting('repair_service persist_directory').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'repair_service',
        'setting' => 'persist_directory',
      })
    }
  end

  context 'repair_service persist_period' do
    let(:title) { 'repair_service persist_period' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'repair_service',
        :setting => 'persist_period',
      }
    end

    it {
      should contain_ini_setting('repair_service persist_period').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'repair_service',
        'setting' => 'persist_period',
      })
    }
  end

  context 'repair_service restart_period' do
    let(:title) { 'repair_service restart_period' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'repair_service',
        :setting => 'restart_period',
      }
    end

    it {
      should contain_ini_setting('repair_service restart_period').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'repair_service',
        'setting' => 'restart_period',
      })
    }
  end

  context 'repair_service single_repair_timeout' do
    let(:title) { 'repair_service single_repair_timeout' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'repair_service',
        :setting => 'single_repair_timeout',
      }
    end

    it {
      should contain_ini_setting('repair_service single_repair_timeout').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'repair_service',
        'setting' => 'single_repair_timeout',
      })
    }
  end

  context 'repair_service single_task_err_threshold' do
    let(:title) { 'repair_service single_task_err_threshold' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'repair_service',
        :setting => 'single_task_err_threshold',
      }
    end

    it {
      should contain_ini_setting('repair_service single_task_err_threshold').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'repair_service',
        'setting' => 'single_task_err_threshold',
      })
    }
  end

  context 'repair_service snapshot_override' do
    let(:title) { 'repair_service snapshot_override' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'repair_service',
        :setting => 'snapshot_override',
      }
    end

    it {
      should contain_ini_setting('repair_service snapshot_override').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'repair_service',
        'setting' => 'snapshot_override',
      })
    }
  end

  context 'request_tracker queue_size' do
    let(:title) { 'request_tracker queue_size' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'request_tracker',
        :setting => 'queue_size',
      }
    end

    it {
      should contain_ini_setting('request_tracker queue_size').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'request_tracker',
        'setting' => 'queue_size',
      })
    }
  end

  context 'security config_encryption_active' do
    let(:title) { 'security config_encryption_active' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'security',
        :setting => 'config_encryption_active',
      }
    end

    it {
      should contain_ini_setting('security config_encryption_active').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'security',
        'setting' => 'config_encryption_active',
      })
    }
  end

  context 'security config_encryption_key_name' do
    let(:title) { 'security config_encryption_key_name' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'security',
        :setting => 'config_encryption_key_name',
      }
    end

    it {
      should contain_ini_setting('security config_encryption_key_name').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'security',
        'setting' => 'config_encryption_key_name',
      })
    }
  end

  context 'security config_encryption_key_path' do
    let(:title) { 'security config_encryption_key_path' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'security',
        :setting => 'config_encryption_key_path',
      }
    end

    it {
      should contain_ini_setting('security config_encryption_key_path').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'security',
        'setting' => 'config_encryption_key_path',
      })
    }
  end

  context 'spark base_master_proxy_port' do
    let(:title) { 'spark base_master_proxy_port' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'spark',
        :setting => 'base_master_proxy_port',
      }
    end

    it {
      should contain_ini_setting('spark base_master_proxy_port').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'spark',
        'setting' => 'base_master_proxy_port',
      })
    }
  end

  context 'stat_reporter initial_sleep' do
    let(:title) { 'stat_reporter initial_sleep' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'stat_reporter',
        :setting => 'initial_sleep',
      }
    end

    it {
      should contain_ini_setting('stat_reporter initial_sleep').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'stat_reporter',
        'setting' => 'initial_sleep',
      })
    }
  end

  context 'stat_reporter interval' do
    let(:title) { 'stat_reporter interval' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'stat_reporter',
        :setting => 'interval',
      }
    end

    it {
      should contain_ini_setting('stat_reporter interval').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'stat_reporter',
        'setting' => 'interval',
      })
    }
  end

  context 'stat_reporter report_file' do
    let(:title) { 'stat_reporter report_file' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'stat_reporter',
        :setting => 'report_file',
      }
    end

    it {
      should contain_ini_setting('stat_reporter report_file').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'stat_reporter',
        'setting' => 'report_file',
      })
    }
  end

  context 'stat_reporter ssl_key' do
    let(:title) { 'stat_reporter ssl_key' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'stat_reporter',
        :setting => 'ssl_key',
      }
    end

    it {
      should contain_ini_setting('stat_reporter ssl_key').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'stat_reporter',
        'setting' => 'ssl_key',
      })
    }
  end

  context 'ui default_api_timeout' do
    let(:title) { 'ui default_api_timeout' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'ui',
        :setting => 'default_api_timeout',
      }
    end

    it {
      should contain_ini_setting('ui default_api_timeout').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'ui',
        'setting' => 'default_api_timeout',
      })
    }
  end

  context 'ui max_metrics_requests' do
    let(:title) { 'ui max_metrics_requests' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'ui',
        :setting => 'max_metrics_requests',
      }
    end

    it {
      should contain_ini_setting('ui max_metrics_requests').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'ui',
        'setting' => 'max_metrics_requests',
      })
    }
  end

  context 'ui node_detail_refresh_delay' do
    let(:title) { 'ui node_detail_refresh_delay' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'ui',
        :setting => 'node_detail_refresh_delay',
      }
    end

    it {
      should contain_ini_setting('ui node_detail_refresh_delay').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'ui',
        'setting' => 'node_detail_refresh_delay',
      })
    }
  end

  context 'ui storagemap_ttl' do
    let(:title) { 'ui storagemap_ttl' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'ui',
        :setting => 'storagemap_ttl',
      }
    end

    it {
      should contain_ini_setting('ui storagemap_ttl').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'ui',
        'setting' => 'storagemap_ttl',
      })
    }
  end

  context 'webserver interface' do
    let(:title) { 'webserver interface' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'webserver',
        :setting => 'interface',
      }
    end

    it {
      should contain_ini_setting('webserver interface').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'webserver',
        'setting' => 'interface',
      })
    }
  end

  context 'webserver log_path' do
    let(:title) { 'webserver log_path' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'webserver',
        :setting => 'log_path',
      }
    end

    it {
      should contain_ini_setting('webserver log_path').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'webserver',
        'setting' => 'log_path',
      })
    }
  end

  context 'webserver port' do
    let(:title) { 'webserver port' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'webserver',
        :setting => 'port',
      }
    end

    it {
      should contain_ini_setting('webserver port').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'webserver',
        'setting' => 'port',
      })
    }
  end

  context 'webserver ssl_certfile' do
    let(:title) { 'webserver ssl_certfile' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'webserver',
        :setting => 'ssl_certfile',
      }
    end

    it {
      should contain_ini_setting('webserver ssl_certfile').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'webserver',
        'setting' => 'ssl_certfile',
      })
    }
  end

  context 'webserver ssl_keyfile' do
    let(:title) { 'webserver ssl_keyfile' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'webserver',
        :setting => 'ssl_keyfile',
      }
    end

    it {
      should contain_ini_setting('webserver ssl_keyfile').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'webserver',
        'setting' => 'ssl_keyfile',
      })
    }
  end

  context 'webserver ssl_port' do
    let(:title) { 'webserver ssl_port' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'webserver',
        :setting => 'ssl_port',
      }
    end

    it {
      should contain_ini_setting('webserver ssl_port').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'webserver',
        'setting' => 'ssl_port',
      })
    }
  end

  context 'webserver staticdir' do
    let(:title) { 'webserver staticdir' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'webserver',
        :setting => 'staticdir',
      }
    end

    it {
      should contain_ini_setting('webserver staticdir').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'webserver',
        'setting' => 'staticdir',
      })
    }
  end

  context 'webserver sub_process_timeout' do
    let(:title) { 'webserver sub_process_timeout' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'webserver',
        :setting => 'sub_process_timeout',
      }
    end

    it {
      should contain_ini_setting('webserver sub_process_timeout').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'webserver',
        'setting' => 'sub_process_timeout',
      })
    }
  end

  context 'webserver tarball_process_timeout' do
    let(:title) { 'webserver tarball_process_timeout' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'webserver',
        :setting => 'tarball_process_timeout',
      }
    end

    it {
      should contain_ini_setting('webserver tarball_process_timeout').with({
        'ensure'  => 'absent',
        'path'    => '/path/to/file',
        'section' => 'webserver',
        'setting' => 'tarball_process_timeout',
      })
    }
  end
end
