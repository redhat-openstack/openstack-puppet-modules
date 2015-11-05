require 'spec_helper_acceptance'

describe 'kafka::broker class' do

  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      if fact('osfamily') == 'RedHat'
        pp = <<-EOS
          class { 'java':
            distribution => 'jre',
          } ->

          class {'zookeeper':
            packages             => ['zookeeper', 'zookeeper-server'],
            service_name         => 'zookeeper-server',
            initialize_datastore => true,
            repo                 => 'cloudera',
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
      else
        pp = <<-EOS
          class { 'java':
            distribution => 'jre',
          } ->

          class {'zookeeper':
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
      end

      pp = <<-EOS
      class { 'kafka::broker':
        config => { 'broker.id' => '0', 'zookeeper.connect' => 'localhost:2181' }
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe user('kafka') do
      it { should exist }
    end

    describe group('kafka') do
      it { should exist }
    end

    describe file('/opt/kafka') do
      it { should be_linked_to('/opt/kafka-2.10-0.8.2.1') }
    end

    describe file('/opt/kafka/bin/kafka-server-start.sh') do
      it { should be_file }
    end

    describe file('/opt/kafka/config/server.properties') do
      it { should be_file }
      its(:content) { should match /broker\.id=0/ }
      its(:content) { should match /log\.dirs=\/tmp\/kafka-logs/ }
      its(:content) { should match /port=6667/ }
    end

    describe file('/etc/init.d/kafka') do
      it { should be_file }
    end

    describe service('kafka') do
      it { should be_running }
    end

  end
end
