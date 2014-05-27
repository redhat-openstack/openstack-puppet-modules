require 'spec_helper_acceptance'

describe 'kafka::broker class' do

  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOS
      include zookeeper
      class { 'kafka::broker':
        config => { 'broker.id' => '0', 'zookeeper.connect' => 'localhost:2181' }
      }
      EOS

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
    end

    describe user('kafka') do
      it { should exist }
    end

    describe group('kafka') do
      it { should exist }
    end

    describe file('/usr/local/kafka') do
      it { should be_linked_to('/usr/local/kafka-2.8.0-0.8.1.1') }
    end

    describe file('/usr/local/kafka/bin/kafka-server-start.sh') do
      it { should be_file }
    end

    describe file('/usr/local/kafka/config/server.properties') do
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
