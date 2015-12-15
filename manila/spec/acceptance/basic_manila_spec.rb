require 'spec_helper_acceptance'

describe 'basic manila' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      include ::openstack_integration
      include ::openstack_integration::repos
      include ::openstack_integration::rabbitmq
      include ::openstack_integration::mysql
      include ::openstack_integration::keystone

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

      # Manila resources
      class { '::manila':
        sql_connection      => 'mysql+pymysql://manila:a_big_secret@127.0.0.1/manila?charset=utf8',
        rabbit_userid       => 'manila',
        rabbit_password     => 'an_even_bigger_secret',
        rabbit_host         => '127.0.0.1',
        debug               => true,
        verbose             => true,
      }
      class { '::manila::db::mysql':
        password => 'a_big_secret',
      }
      class { '::manila::keystone::auth':
        password    => 'a_big_secret',
        password_v2 => 'a_big_secret',
      }
      class { '::manila::client': }
      class { '::manila::compute::nova': }
      class { '::manila::network::neutron': }
      class { '::manila::volume::cinder': }
      class { '::manila::api':
        keystone_password     => 'a_big_secret',
      }
      class { '::manila::scheduler': }

      # NFS-Ganesha backend. Currently this feature is only for RHEL systems
      # because Debian/Ubuntu systems do not have nfs-ganesha package yet.
      class { '::manila::ganesha': }

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
