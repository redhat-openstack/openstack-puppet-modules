require 'spec_helper_acceptance'

describe 'cassandra class' do
  cassandra_pp = <<-EOS
    class { 'cassandra':
      manage_dsc_repo   => true,
    }

    include '::cassandra::datastax_agent'
    include '::cassandra::java'

    class { '::cassandra::opscenter::pycrypto':
      manage_epel => true
    }

    include '::cassandra::optutils'
  EOS

  describe 'Initial install.' do
    it 'should work with no errors' do
      apply_manifest(cassandra_pp, :catch_failures => true)
    end
  end

  idempotency_pp = <<-EOS
    include 'cassandra'
    include '::cassandra::datastax_agent'
    include '::cassandra::java'
    include '::cassandra::opscenter::pycrypto'
    include '::cassandra::optutils'
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

end
