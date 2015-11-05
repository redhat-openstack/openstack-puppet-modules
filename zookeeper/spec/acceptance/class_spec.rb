require 'spec_helper_acceptance'

describe 'zookeeper class' do

  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOS
      class { 'zookeeper': }
      EOS

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
    end

    # TODO: Actually implement some acceptance tests.
    describe package('zookeeper') do
      # The following test does not work yet because we first need to add a yum repository to the test VM from which
      # Puppet can retrieve the ZooKeeper (RPM) package.
      #it { should be_installed }
    end

    # This is an example serverspec test (http://serverspec.org/).
    # Vagrant machines will always run an SSH server by default, so this test should always work.
    describe port(22) do
        it { should be_listening }
    end

  end
end
