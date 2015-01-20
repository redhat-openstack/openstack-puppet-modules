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
      it { is_expected.to be_installed }
    end

    describe service('opendaylight') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end
  end
end
