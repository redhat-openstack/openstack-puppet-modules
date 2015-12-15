require 'spec_helper_acceptance'

describe 'basic cinder' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      include ::openstack_integration
      include ::openstack_integration::repos
      include ::openstack_integration::rabbitmq
      include ::openstack_integration::mysql
      include ::openstack_integration::keystone

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

      # Cinder resources
      class { '::cinder':
        database_connection => 'mysql+pymysql://cinder:a_big_secret@127.0.0.1/cinder?charset=utf8',
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
