require 'spec_helper_acceptance'

describe 'basic aodh' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      Exec { logoutput => 'on_failure' }

      # Common resources
      case $::osfamily {
        'Debian': {
          include ::apt
          class { '::openstack_extras::repo::debian::ubuntu':
            release         => 'liberty',
            repo            => 'proposed',
            package_require => true,
          }
          $package_provider = 'apt'
        }
        'RedHat': {
          class { '::openstack_extras::repo::redhat::redhat':
            manage_rdo => false,
            repo_hash => {
              'openstack-common-testing' => {
                'baseurl'  => 'http://cbs.centos.org/repos/cloud7-openstack-common-testing/x86_64/os/',
                'descr'    => 'openstack-common-testing',
                'gpgcheck' => 'no',
              },
              'openstack-liberty-testing' => {
                'baseurl'  => 'http://cbs.centos.org/repos/cloud7-openstack-liberty-testing/x86_64/os/',
                'descr'    => 'openstack-liberty-testing',
                'gpgcheck' => 'no',
              },
              'openstack-liberty-trunk' => {
                'baseurl'  => 'http://trunk.rdoproject.org/centos7-liberty/current-passed-ci/',
                'descr'    => 'openstack-liberty-trunk',
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

      rabbitmq_user { 'aodh':
        admin    => true,
        password => 'an_even_bigger_secret',
        provider => 'rabbitmqctl',
        require  => Class['rabbitmq'],
      }

      rabbitmq_user_permissions { 'aodh@/':
        configure_permission => '.*',
        write_permission     => '.*',
        read_permission      => '.*',
        provider             => 'rabbitmqctl',
        require              => Class['rabbitmq'],
      }


      # Keystone resources, needed by Ceilometer to run
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
      class { '::aodh':
        rabbit_userid   => 'aodh',
        rabbit_password => 'an_even_bigger_secret',
        verbose         => true,
        debug           => true,
        rabbit_host     => '127.0.0.1',
      }
      class { '::aodh::db::mysql':
        password => 'a_big_secret',
      }
      class { '::aodh::keystone::auth':
        password => 'a_big_secret',
      }
      EOS


      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

  end
end
