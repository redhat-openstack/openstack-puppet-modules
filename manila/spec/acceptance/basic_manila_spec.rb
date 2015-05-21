require 'spec_helper_acceptance'

describe 'basic manila' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      Exec { logoutput => 'on_failure' }

      # Common resources
      case $::osfamily {
        'Debian': {
          include ::apt
          class { '::openstack_extras::repo::debian::ubuntu':
            release         => 'kilo',
            package_require => true,
          }
          $package_provider = 'apt'
        }
        'RedHat': {
          class { '::openstack_extras::repo::redhat::redhat':
            # Kilo is not GA yet, so let's use the testing repo
            manage_rdo => false,
            repo_hash  => {
              'rdo-kilo-testing' => {
                'baseurl'  => 'https://repos.fedorapeople.org/repos/openstack/openstack-kilo/testing/el7/',
                # packages are not GA so not signed
                'gpgcheck' => '0',
                'priority' => 97,
              },
            },
          }
          $package_provider = 'yum'
        }
        default: {
          fail("Unsupported osfamily (${::osfamily})")
        }
      }

      class { '::mysql::server': }

      class { '::rabbitmq':
        delete_guest_user => true,
        erlang_cookie     => 'secrete',
        package_provider => $package_provider,
      }

      rabbitmq_vhost { '/':
        provider => 'rabbitmqctl',
        require  => Class['rabbitmq'],
      }

      rabbitmq_user { 'manila':
        admin    => true,
        password => 'an_even_bigger_secret',
        provider => 'rabbitmqctl',
        require  => Class['rabbitmq'],
      }

      rabbitmq_user_permissions { 'manila@/':
        configure_permission => '.*',
        write_permission     => '.*',
        read_permission      => '.*',
        provider             => 'rabbitmqctl',
        require              => Class['rabbitmq'],
      }

      # Keystone resources, needed by Manila to run
      class { '::keystone::db::mysql':
        password => 'keystone',
      }
      class { '::keystone':
        verbose             => true,
        debug               => true,
        database_connection => 'mysql://keystone:keystone@127.0.0.1/keystone',
        admin_token         => 'admin_token',
        enabled             => true,
      }
      class { '::keystone::roles::admin':
        email    => 'test@example.tld',
        password => 'a_big_secret',
      }
      class { '::keystone::endpoint':
        public_url => "https://${::fqdn}:5000/",
        admin_url  => "https://${::fqdn}:35357/",
      }

      # Manila resources
      class { '::manila':
        sql_connection      => 'mysql://manila:a_big_secret@127.0.0.1/manila?charset=utf8',
        rabbit_userid       => 'manila',
        rabbit_password     => 'an_even_bigger_secret',
        rabbit_host         => '127.0.0.1',
      }
      class { '::manila::db::mysql':
        password => 'a_big_secret',
      }
      class { '::manila::keystone::auth':
        password => 'a_big_secret',
      }
      class { '::manila::client': }
      class { '::manila::compute::nova': }
      class { '::manila::network::neutron': }
      class { '::manila::volume::cinder': }
      class { '::manila::api':
        keystone_password     => 'a_big_secret',
      }
      class { '::manila::scheduler': }

      # missing: backends, share, service_instance
      EOS


      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe port(8786) do
      it { is_expected.to be_listening.with('tcp') }
    end

  end
end
