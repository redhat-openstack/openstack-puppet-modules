require 'spec_helper_acceptance'

describe 'cassandra class' do
  pp1 = <<-EOS
    class { 'cassandra':
      manage_dsc_repo   => true,
    }

    include '::cassandra::java'
  EOS

  describe 'Install Cassandra with Java.' do
    it 'should work with no errors' do
      apply_manifest(pp1, :catch_failures => true)
    end
  end

  pp2 = <<-EOS
    class { 'cassandra':
      cassandra_opt_package_ensure => 'present',
    }
  EOS

  describe 'Install the Optional Cassandra tools.' do
    it 'should work with no errors' do
      apply_manifest(pp2, :catch_failures => true)
    end
  end

  pp3 = <<-EOS
    include '::cassandra'
    include '::cassandra::datastax_agent'
  EOS

  describe 'Install the DataStax Agent.' do
    it 'should work with no errors' do
      apply_manifest(pp3, :catch_failures => true)
    end
  end

  pp4 = <<-EOS
    class { 'cassandra':
      manage_dsc_repo              => true,
      cassandra_opt_package_ensure => 'present',
    }

    include '::cassandra::datastax_agent'
    include '::cassandra::java'
  EOS

  describe 'Idempotency test.' do
    it 'should work with no errors' do
      expect(apply_manifest(pp3, :catch_failures => true).exit_code).to be_zero
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
