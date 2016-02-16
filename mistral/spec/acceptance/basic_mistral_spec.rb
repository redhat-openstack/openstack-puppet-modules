require 'spec_helper_acceptance'

describe 'basic mistral' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      include ::openstack_integration
      include ::openstack_integration::repos
      include ::openstack_integration::rabbitmq
      include ::openstack_integration::mysql
      include ::openstack_integration::keystone

      rabbitmq_user { 'mistral':
        admin    => true,
        password => 'an_even_bigger_secret',
        provider => 'rabbitmqctl',
        require  => Class['rabbitmq'],
      }

      rabbitmq_user_permissions { 'mistral@/':
        configure_permission => '.*',
        write_permission     => '.*',
        read_permission      => '.*',
        provider             => 'rabbitmqctl',
        require              => Class['rabbitmq'],
      }

      # Mistral resources
      case $::osfamily {
        'Debian': {
          warning('Mistral is not yet packaged on Ubuntu systems.')
        }
        'RedHat': {
          class { '::mistral':
            database_connection => 'mysql+pymysql://mistral:a_big_secret@127.0.0.1/mistral?charset=utf8',
            keystone_password   => 'a_big_secret',
            rabbit_userid       => 'mistral',
            rabbit_password     => 'an_even_bigger_secret',
            rabbit_host         => '127.0.0.1',
            debug               => true,
            verbose             => true,
          }
          class { '::mistral::keystone::auth':
            password => 'a_big_secret',
          }
          class { '::mistral::db::mysql':
            password => 'a_big_secret',
          }
          class { '::mistral::api': }
          class { '::mistral::client': }
          class { '::mistral::engine': }
          class { '::mistral::executor': }
          class { '::mistral::db::sync': }
        }
      }
      EOS


      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    if os[:family].casecmp('RedHat') == 0
      describe port(8989) do
        it { is_expected.to be_listening.with('tcp') }
      end
    end

  end

end
