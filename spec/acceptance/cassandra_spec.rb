require 'spec_helper_acceptance'

describe 'cassandra class' do
  describe 'Install Cassandra with Java.' do
    it 'should work with no errors' do
      pp = <<-EOS
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

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end
  end

  describe 'Install the DataStax Agent.' do
    it 'should work with no errors' do
      pp = <<-EOS
        class { 'cassandra':
          datastax_agent_package_ensure => 'present',
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end
  end
end
