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
      it 'should produce consistent uchiwa.json file' do

        uchiwa_json = "{\n\"sensu\": [\n    {\n      \"name\": \"Main Server\",\n      \"host\": \"127.0.0.1\",\n      \"ssl\": false,\n      \"insecure\": false,\n      \"port\": 4567,\n      \"user\": \"sensu\",\n      \"pass\": \"secret\",\n      \"path\": \"\",\n      \"timeout\": 5000\n    }\n  ],\n  \"uchiwa\": {\n    \"host\": \"0.0.0.0\",\n    \"port\": 3000,\n    \"user\": \"\",\n    \"pass\": \"\",\n    \"refresh\": 5\n  }\n}\n"

        shell('cat /etc/sensu/uchiwa.json') do |cat|
          expect(cat.stdout).to eq (uchiwa_json)
        end
      end

      describe file('/etc/sensu/uchiwa.json') do
        it { should be_owned_by 'uchiwa' }
        it { should be_grouped_into 'uchiwa' }
        it { should be_mode 440 }
      end

      it 'rerun puppet with default params' do
        
        pp = <<-EOS

        include ::uchiwa

        EOS
        expect(apply_manifest(pp, :catch_failures => true).exit_code)
      end

      it 'should produce a uchiwa.json file from defaults' do

        uchiwa_json = "{\n\"sensu\": [\n    {\n      \"name\": \"sensu\",\n      \"host\": \"127.0.0.1\",\n      \"ssl\": false,\n      \"insecure\": false,\n      \"port\": 4567,\n      \"user\": \"sensu\",\n      \"pass\": \"sensu\",\n      \"path\": \"\",\n      \"timeout\": 5000\n    }\n  ],\n  \"uchiwa\": {\n    \"host\": \"0.0.0.0\",\n    \"port\": 3000,\n    \"user\": \"\",\n    \"pass\": \"\",\n    \"refresh\": 5\n  }\n}\n"

        shell('cat /etc/sensu/uchiwa.json') do |cat|
          expect(cat.stdout).to eq (uchiwa_json)
        end
      end
    end   
  end
end
