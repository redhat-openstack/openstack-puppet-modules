require 'spec_helper_acceptance'

if hosts.length == 1
  describe "running puppet" do
    it 'should be able to apply class haproxy' do
      pp = <<-EOS
      class { 'haproxy':
        custom_fragment => "listen stats :9090
          mode http
          stats uri /
          stats auth puppet:puppet",
      }
      haproxy::listen { 'test00': ports => '80',}
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    it 'should have stats listening' do
      shell("/usr/bin/curl -u puppet:puppet localhost:9090") do |r|
        r.stdout.should =~ /HAProxy/
        r.exit_code.should == 0
      end
    end
  end
end
