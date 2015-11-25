require 'spec_helper_acceptance'

describe 'basic gnocchi' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      include ::openstack_integration
      include ::openstack_integration::repos
      include ::openstack_integration::mysql
      include ::openstack_integration::keystone

      class { '::gnocchi::db::mysql':
        password => 'a_big_secret',
      }
      class { '::gnocchi::keystone::auth':
        password => 'a_big_secret',
      }
      case $::osfamily {
        'Debian': {
          warning('Gnocchi is not yet packaged on Ubuntu systems.')
        }
        'RedHat': {
          class { '::gnocchi':
            verbose             => true,
            debug               => true,
            database_connection => 'mysql://gnocchi:a_big_secret@127.0.0.1/gnocchi?charset=utf8',
          }
          class { '::gnocchi::api':
            enabled               => true,
            keystone_password     => 'a_big_secret',
            keystone_identity_uri => 'http://127.0.0.1:35357/',
            service_name          => 'httpd',
          }
          class { '::gnocchi::db::sync': }
          class { '::gnocchi::storage': }
          class { '::gnocchi::storage::file': }
          include ::apache
          class { '::gnocchi::wsgi::apache':
            ssl => false,
          }
        }
      }
      EOS


      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    if os[:family].casecmp('RedHat') == 0
      describe port(8041) do
        it { is_expected.to be_listening }
      end
    end

  end
end
