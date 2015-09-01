require 'spec_helper_acceptance'

describe 'basic manila_config resource' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      Exec { logoutput => 'on_failure' }

      File <||> -> Manila_config <||>

      file { '/etc/manila' :
        ensure => directory,
      }
      file { '/etc/manila/manila.conf' :
        ensure => file,
      }

      manila_config { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      manila_config { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      manila_config { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      manila_config { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }
      EOS


      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file('/etc/manila/manila.conf') do
      it { should exist }
      it { should contain('thisshouldexist=foo') }
      it { should contain('thisshouldexist2=<SERVICE DEFAULT>') }

      its(:content) { should_not match /thisshouldnotexist/ }
    end


  end
end
