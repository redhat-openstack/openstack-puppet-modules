require 'spec_helper_acceptance'

describe 'cassandra class' do
  cassandra_pp = <<-EOS
    require '::cassandra::datastax_repo'
    require '::cassandra::java'

    class { 'cassandra':
      cassandra_9822  => true
    }

    include '::cassandra::datastax_agent'

    class { '::cassandra::opscenter::pycrypto':
      manage_epel => true,
      before      => Class['::cassandra::opscenter']
    }

    include '::cassandra::opscenter'
    include '::cassandra::optutils'
    include '::cassandra::firewall_ports'
  EOS

  describe 'Initial install.' do
    it 'should work with no errors' do
      apply_manifest(cassandra_pp, :catch_failures => true)
    end
  end

  idempotency_pp = <<-EOS
    require '::cassandra::datastax_repo'
    require '::cassandra::java'

    class { 'cassandra':
      cassandra_9822  => true
    }

    include '::cassandra::datastax_agent'

    class { '::cassandra::opscenter::pycrypto':
      manage_epel => true,
      before      => Class['::cassandra::opscenter']
    }

    include '::cassandra::opscenter'
    include '::cassandra::optutils'
    include '::cassandra::firewall_ports'
  EOS

  describe 'Idempotency test.' do
    it 'should work with no errors' do
      expect(apply_manifest(idempotency_pp, :catch_failures => true).exit_code).to be_zero
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
