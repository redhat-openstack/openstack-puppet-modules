require 'spec_helper_acceptance'

describe 'sensu class', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do

  context 'uchiwa' do
    context 'ensure => present' do
      it 'should work with no errors' do
        pp = <<-EOS
        class { 'rabbitmq':
          package_ensure    => installed,
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
          install_repo        => false,
          sensu_api_endpoints =>  [{
                                    name      => 'Main Server',
                                    host      => '127.0.0.1',
                                    ssl       => false,
                                    insecure  => false,
                                    port      => 4567,
                                    user      => 'sensu',
                                    pass      => 'secret',
                                    path      => '',
                                    timeout   => 5000
                                    }],
          require             => Class['sensu'],
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
