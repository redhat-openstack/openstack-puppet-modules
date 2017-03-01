require 'spec_helper_acceptance'

describe 'basic tempest' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      Exec { logoutput => 'on_failure' }

      class { '::tempest':
        setup_venv         => true,
        configure_images   => false,
        configure_networks => false,
      }
      EOS


      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

  end
end
