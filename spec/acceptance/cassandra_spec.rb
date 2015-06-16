require 'spec_helper_acceptance'

describe 'cassandra class' do
  describe 'running puppet code' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOS
        class { 'cassandra': manage_dsc_repo => true }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end
  end
end
