require 'spec_helper_acceptance'

describe 'kafka class' do

  context 'default parameters' do
    it 'should work with no errors' do
      if fact('osfamily') == 'RedHat'
        pp = <<-EOS
          class { 'java':
            distribution => 'jre',
          } ->

          class {'zookeeper':
            packages             => ['zookeeper', 'zookeeper-server'],
            service_name         => 'zookeeper-server',
            initialize_datastore => true,
            repo                 => 'cloudera',
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
      else
        pp = <<-EOS
          class { 'java':
            distribution => 'jre',
          } ->

          class {'zookeeper':
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
      end

      pp = <<-EOS
        class { 'kafka': }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end
end
