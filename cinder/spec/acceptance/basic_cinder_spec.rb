require 'spec_helper_acceptance'

describe 'basic cinder' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      Exec { logoutput => 'on_failure' }

      # Common resources
      case $::osfamily {
        'Debian': {
          include ::apt
          apt::ppa { 'ppa:ubuntu-cloud-archive/liberty-staging':
            # it's false by default in 2.x series but true in 1.8.x
            package_manage => false,
          }
          Exec['apt_update'] -> Package<||>
          $package_provider = 'apt'
        }
        'RedHat': {
          class { '::openstack_extras::repo::redhat::redhat':
            manage_rdo => false,
            repo_hash => {
              # we need kilo repo to be installed for dependencies
              'rdo-kilo' => {
                'baseurl' => 'https://repos.fedorapeople.org/repos/openstack/openstack-kilo/el7/',
                'descr'   => 'RDO kilo',
                'gpgcheck' => 'no',
              },
              'rdo-liberty' => {
                'baseurl'  => 'http://trunk.rdoproject.org/centos7/current/',
                'descr'    => 'RDO trunk',
                'gpgcheck' => 'no',
              },
            },
          }
          package { 'openstack-selinux': ensure => 'latest' }
          $package_provider = 'yum'
        }
        default: {
          fail("Unsupported osfamily (${::osfamily})")
        }
      }

      class { '::mysql::server': }

      class { '::rabbitmq':
        delete_guest_user => true,
        package_provider  => $package_provider,
      }

      rabbitmq_vhost { '/':
        provider => 'rabbitmqctl',
        require  => Class['rabbitmq'],
      }

      rabbitmq_user { 'cinder':
        admin    => true,
        password => 'an_even_bigger_secret',
        provider => 'rabbitmqctl',
        require  => Class['rabbitmq'],
      }

      rabbitmq_user_permissions { 'cinder@/':
        configure_permission => '.*',
        write_permission     => '.*',
        read_permission      => '.*',
        provider             => 'rabbitmqctl',
        require              => Class['rabbitmq'],
      }

      # Keystone resources, needed by Cinder to run
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

      # Cinder resources
      class { '::cinder':
        database_connection => 'mysql://cinder:a_big_secret@127.0.0.1/cinder?charset=utf8',
        rabbit_userid       => 'cinder',
        rabbit_password     => 'an_even_bigger_secret',
        rabbit_host         => '127.0.0.1',
        debug               => true,
        verbose             => true,
      }
      class { '::cinder::keystone::auth':
        password => 'a_big_secret',
      }
      class { '::cinder::db::mysql':
        password => 'a_big_secret',
      }
      class { '::cinder::api':
        keystone_password   => 'a_big_secret',
        identity_uri        => 'http://127.0.0.1:35357/',
        default_volume_type => 'iscsi_backend',
      }
      class { '::cinder::backup': }
      class { '::cinder::ceilometer': }
      class { '::cinder::client': }
      class { '::cinder::quota': }
      class { '::cinder::scheduler': }
      class { '::cinder::scheduler::filter': }
      class { '::cinder::volume': }
      class { '::cinder::cron::db_purge': }
      # TODO: create a backend and spawn a volume
      EOS


      # Run it twice to test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe port(8776) do
      it { is_expected.to be_listening.with('tcp') }
    end

    describe cron do
      it { is_expected.to have_entry('1 0 * * * cinder-manage db purge 30 >>/var/log/cinder/cinder-rowsflush.log 2>&1').with_user('cinder') }
    end


  end
end
