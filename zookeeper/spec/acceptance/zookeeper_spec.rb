require 'spec_helper_acceptance'

describe 'zookeeper defintion', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do

  context 'basic setup' do

    it 'install zookeeper' do
      pp = <<-EOS
        class{'zookeeper': }
      EOS

      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
   end

   describe file('/etc/zookeeper') do
     it { should be_directory }
   end
 end

end