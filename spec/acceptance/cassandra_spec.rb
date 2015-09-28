require 'spec_helper_acceptance'

describe 'cassandra class' do
  pre_req_install_pp = <<-EOS
    include '::cassandra::datastax_repo'
    include '::cassandra::java'
  EOS

  describe 'Pre-requisits installation.' do
    it 'should work with no errors' do
      apply_manifest(pre_req_install_pp, :catch_failures => true)
    end
    it 'check code is idempotent' do
      expect(apply_manifest(pre_req_install_pp, :catch_failures => true).exit_code).to be_zero
    end
  end

  cassandra_install_pp = <<-EOS
    class { 'cassandra':
      cassandra_9822              => true,
      commitlog_directory_mode    => '0770',
      data_file_directories_mode  => '0770',
      saved_caches_directory_mode => '0770'
    }
  EOS

  describe 'Cassandra installation.' do
    it 'should work with no errors' do
      apply_manifest(cassandra_install_pp, :catch_failures => true)
    end
    it 'check code is idempotent' do
      expect(apply_manifest(cassandra_install_pp, :catch_failures => true).exit_code).to be_zero
    end
  end

  optutils_install_pp = <<-EOS
    class { 'cassandra':
      cassandra_9822              => true,
      commitlog_directory_mode    => '0770',
      data_file_directories_mode  => '0770',
      saved_caches_directory_mode => '0770'
    }
    include '::cassandra::optutils'
  EOS

  describe 'Cassandra optional utilities installation.' do
    it 'should work with no errors' do
      apply_manifest(optutils_install_pp, :catch_failures => true)
    end
    it 'check code is idempotent' do
      expect(apply_manifest(optutils_install_pp, :catch_failures => true).exit_code).to be_zero
    end
  end

  datastax_agent_install_pp = <<-EOS
    class { 'cassandra':
      cassandra_9822              => true,
      commitlog_directory_mode    => '0770',
      data_file_directories_mode  => '0770',
      saved_caches_directory_mode => '0770'
    }
    include '::cassandra::datastax_agent'
  EOS

  describe 'DataStax agent installation.' do
    it 'should work with no errors' do
      apply_manifest(datastax_agent_install_pp, :catch_failures => true)
    end
    it 'check code is idempotent' do
      expect(apply_manifest(datastax_agent_install_pp, :catch_failures => true).exit_code).to be_zero
    end
  end

  opscenter_install_pp = <<-EOS
    class { '::cassandra::opscenter::pycrypto':
      manage_epel => true,
      before      => Class['::cassandra::opscenter']
    }

    include '::cassandra::opscenter'
  EOS

  describe 'OpsCenter installation.' do
    it 'should work with no errors' do
      apply_manifest(opscenter_install_pp, :catch_failures => true)
    end
    it 'check code is idempotent' do
      expect(apply_manifest(opscenter_install_pp, :catch_failures => true).exit_code).to be_zero
    end
  end

  firewall_config_pp = <<-EOS
    class { 'cassandra':
      cassandra_9822              => true,
      commitlog_directory_mode    => '0770',
      data_file_directories_mode  => '0770',
      saved_caches_directory_mode => '0770'
    }
    include '::cassandra::optutils'
    include '::cassandra::datastax_agent'
    include '::cassandra::opscenter'
    include '::cassandra::opscenter::pycrypto'
    include '::cassandra::firewall_ports'
  EOS

  describe 'Firewall configuration.' do
    it 'should work with no errors' do
      apply_manifest(firewall_config_pp, :catch_failures => true)
    end
    it 'check code is idempotent' do
      expect(apply_manifest(firewall_config_pp, :catch_failures => true).exit_code).to be_zero
    end
  end

  describe service('cassandra') do
    it { is_expected.to be_running }
    it { is_expected.to be_enabled }
  end

  describe service('datastax-agent') do
    it { is_expected.to be_running }
    it { is_expected.to be_enabled }
  end

  describe service('opscenterd') do
    it { is_expected.to be_running }
    it { is_expected.to be_enabled }
  end
end
