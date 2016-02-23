require 'spec_helper_acceptance'

describe 'basic zaqar' do

  context 'default parameters' do

    it 'zaqar with mongo should work with no errors' do
      pp= <<-EOS
      include ::openstack_integration
      include ::openstack_integration::repos
      include ::openstack_integration::mysql
      include ::openstack_integration::keystone

      class { '::zaqar::keystone::auth':
        password => 'a_big_secret',
      }

      include ::mongodb::globals
      include ::mongodb::client
      class { '::mongodb::server':
        replset         => 'zaqar',
        replset_members => ['127.0.0.1:27017'],
      }
      $zaqar_mongodb_conn_string = 'mongodb://127.0.0.1:27017'

      case $::osfamily {
        'Debian': {
          warning('Zaqar is not yet packaged on Ubuntu systems.')
        }
        'RedHat': {
          Mongodb_replset['zaqar'] -> Package['zaqar-common']
          class {'::zaqar::management::mongodb':
            uri => $zaqar_mongodb_conn_string
          }
          class {'::zaqar::messaging::mongodb':
            uri => $zaqar_mongodb_conn_string
          }
          class {'::zaqar':
            admin_password => 'a_big_secret',
            unreliable     => true,
          }
          include ::zaqar::server
          # run a second instance using websockets
          zaqar::server_instance{ '1':
            transport => 'websocket'
          }
        }
      }
      EOS


      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    if os[:family].casecmp('RedHat') == 0
      describe port(8888) do
        it { is_expected.to be_listening.with('tcp') }
      end
    end

  end

end
