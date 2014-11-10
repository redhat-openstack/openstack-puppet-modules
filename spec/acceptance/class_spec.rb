require 'spec_helper_acceptance'

describe 'sensu class', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do

  context 'uchiwa' do
    context 'ensure => present' do
      it 'should work with no errors' do
        pp = <<-EOS
        class { 'rabbitmq':
          ssl               => false,
          delete_guest_user => true,
        }
        -> rabbitmq_vhost { 'sensu': }
        -> rabbitmq_user  { 'sensu': password => 'secret' }
        -> rabbitmq_user_permissions { 'sensu@sensu':
          configure_permission => '.*',
          read_permission      => '.*',
          write_permission     => '.*',
        }
        class { 'redis': }
        class { 'sensu':
          server                   => true,
          api                      => true,
          purge_config             => true,
          rabbitmq_password        => 'secret',
          rabbitmq_host            => 'localhost',
        }

        class { 'uchiwa':
          install_repo  => false,
          require       => Class['sensu'],
        }

        uchiwa::api { 'Main Server':
          host     => '192.168.50.4',
          ssl      => false,
          insecure => false,
          port     => 4567,
          user     => 'sensu',
          pass     => 'secret',
          path     => '',
          timeout  => 5000
        }

        EOS

        # Run it twice and test for idempotency
        expect(apply_manifest(pp, :catch_failures => true).exit_code)
        expect(apply_manifest(pp, :catch_failures => true).exit_code)
      end
      it 'should start uchiwa' do
        shell('curl localhost:3000/') do |curl|
          expect(curl.stdout).to include '<html lang="en" ng-app="uchiwa" ng-controller="init">'
        end
      end
    end
  end
end