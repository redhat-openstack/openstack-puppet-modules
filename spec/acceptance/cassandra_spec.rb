require 'spec_helper_acceptance'

describe 'cassandra class' do
  cassandra_pp = <<-EOS
    class { '::cassandra::datastax_repo': } ->
    class { '::cassandra::java': } ->
    class { 'cassandra':
      cassandra_9822  => true
    } ->
    class { '::cassandra::optutils': } ->
    class { '::cassandra::datastax_agent': } ->
    class { '::cassandra::opscenter::pycrypto':
      manage_epel => true,
    } ->
    class { '::cassandra::opscenter': } ->
    class { '::cassandra::firewall_ports': }

    # A workaround for Issue79.
    if $::osfamily == 'Debian' {
      exec { '/bin/chown root:root /etc/apt/sources.list.d/datastax.list':
        refreshonly => true,
        subscribe   => Class[::cassandra::datastax_agent]
      }
    }
  EOS

  describe 'Initial install.' do
    it 'should work with no errors' do
      apply_manifest(cassandra_pp, :catch_failures => true)
    end
  end

  describe 'Idempotency test.' do
    it 'should work with no errors' do
      expect(apply_manifest(cassandra_pp, :catch_failures => true).exit_code).to be_zero
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
