require 'spec_helper_acceptance'

describe 'cassandra class' do
  pp1 = <<-EOS
    if $::osfamily == 'Debian' {
      $java_package_name = 'openjdk-7-jre-headless'
    } else {
      $java_package_name = 'java-1.7.0-openjdk'
    }

    class { 'cassandra':
      java_package_name => $java_package_name,
      manage_dsc_repo   => true,
    }
  EOS

  describe 'Install Cassandra with Java 1 of 2.' do
    it 'should work with no errors' do
      apply_manifest(pp1, :catch_failures => true)
    end
  end

  describe 'Install Cassandra with Java 2 of 2.' do
    it 'should work with no errors' do
      expect(apply_manifest(pp1, :catch_failures => true).exit_code).to be_zero
    end
  end

  pp2 = <<-EOS
    class { 'cassandra':
      cassandra_opt_package_ensure => 'present',
    }
  EOS

  describe 'Install the Optional Cassandra tools 1 of 2.' do
    it 'should work with no errors' do
      apply_manifest(pp2, :catch_failures => true)
    end
  end

  describe 'Install the Optional Cassandra tools 2 of 2.' do
    it 'should work with no errors' do
      expect(apply_manifest(pp2, :catch_failures => true).exit_code).to be_zero
    end
  end

  pp3 = <<-EOS
    class { 'cassandra':
      datastax_agent_package_ensure => 'present',
    }
  EOS

  describe 'Install the DataStax Agent 1 of 2.' do
    it 'should work with no errors' do
      apply_manifest(pp3, :catch_failures => true)
    end
  end

  describe 'Install the DataStax Agent 2 of 2.' do
    it 'should work with no errors' do
      expect(apply_manifest(pp3, :catch_failures => true).exit_code).to be_zero
    end
  end
end
