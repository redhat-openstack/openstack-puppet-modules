require 'spec_helper_acceptance'

describe 'cassandra class' do
  pp1 = <<-EOS
    include ::cassandra::opscenter::pycrypto
  EOS

  describe 'Install Cassandra with Java.' do
    it 'should work with no errors' do
      apply_manifest(pp1, :catch_failures => true)
    end
  end
end
