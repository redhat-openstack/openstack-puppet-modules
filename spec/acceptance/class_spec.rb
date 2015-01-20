require 'spec_helper_acceptance'

describe 'opendaylight class' do

  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work idempotently with no errors' do
      pp = <<-EOS
      class { 'opendaylight': }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    describe yumrepo('opendaylight') do
      it { should exist }
      it { should be_enabled }
    end

    describe package('opendaylight') do
      it { should be_installed }
    end

    describe service('opendaylight') do
      it { should be_enabled }
      it { should be_enabled.with_level(3) }
      it { should be_running }
    end

    # OpenDaylight will appear as a Java process
    describe process('java') do
      it { should be_running }
    end

    describe user('odl') do
      it { should exist }
      it { should belong_to_group 'odl' }
      it { should_not have_home_directory '/home/odl' }
    end
  end
end
