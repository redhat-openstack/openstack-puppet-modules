require 'spec_helper_acceptance'

describe 'basic keystone server with resources' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      # make sure apache is stopped before keystone eventlet
      # in case of wsgi was run before
      class { '::apache':
        service_ensure => 'stopped',
      }
      Service['httpd'] -> Service['keystone']

      include ::openstack_integration
      include ::openstack_integration::repos
      include ::openstack_integration::mysql

      # Keystone resources
      class { '::keystone::client': }
      class { '::keystone::cron::token_flush': }
      class { '::keystone::db::mysql':
        password => 'keystone',
      }
      class { '::keystone':
        verbose             => true,
        debug               => true,
        database_connection => 'mysql+pymysql://keystone:keystone@127.0.0.1/keystone',
        admin_token         => 'admin_token',
        enabled             => true,
      }
      # "v2" admin and service
      class { '::keystone::roles::admin':
        email                  => 'test@example.tld',
        password               => 'a_big_secret',
      }
      # Default Keystone endpoints use localhost, default ports and v2.0
      class { '::keystone::endpoint':
        default_domain => 'admin',
      }
      ::keystone::resource::service_identity { 'beaker-ci':
        service_type        => 'beaker',
        service_description => 'beaker service',
        service_name        => 'beaker',
        password            => 'secret',
        public_url          => 'http://127.0.0.1:1234',
        admin_url           => 'http://127.0.0.1:1234',
        internal_url        => 'http://127.0.0.1:1234',
      }
      # v3 admin
      # we don't use ::keystone::roles::admin but still create resources manually:
      keystone_domain { 'admin_domain':
        ensure      => present,
        enabled     => true,
        description => 'Domain for admin v3 users',
      }
      keystone_domain { 'service_domain':
        ensure      => present,
        enabled     => true,
        description => 'Domain for admin v3 users',
      }
      keystone_tenant { 'servicesv3':
        ensure      => present,
        enabled     => true,
        description => 'Tenant for the openstack services',
        domain      => 'service_domain',
      }
      keystone_tenant { 'openstackv3::admin_domain':
        ensure      => present,
        enabled     => true,
        description => 'admin tenant'
      }
      keystone_user { 'adminv3::admin_domain':
        ensure      => present,
        enabled     => true,
        email       => 'test@example.tld',
        password    => 'a_big_secret',
      }
      keystone_user_role { 'adminv3@openstackv3':
        project_domain => 'admin_domain',
        user_domain    => 'admin_domain',
        ensure         => present,
        roles          => ['admin'],
      }
      # service user exists only in the service_domain - must
      # use v3 api
      ::keystone::resource::service_identity { 'beaker-civ3::service_domain':
        service_type        => 'beakerv3',
        service_description => 'beakerv3 service',
        service_name        => 'beakerv3',
        password            => 'secret',
        tenant              => 'servicesv3::service_domain',
        public_url          => 'http://127.0.0.1:1234/v3',
        admin_url           => 'http://127.0.0.1:1234/v3',
        internal_url        => 'http://127.0.0.1:1234/v3',
        user_domain         => 'service_domain',
        project_domain      => 'service_domain',
      }
      EOS


      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe port(5000) do
      it { is_expected.to be_listening.with('tcp') }
    end

    describe port(35357) do
      it { is_expected.to be_listening.with('tcp') }
    end

    describe cron do
      it { is_expected.to have_entry('1 0 * * * keystone-manage token_flush >>/var/log/keystone/keystone-tokenflush.log 2>&1').with_user('keystone') }
    end

    shared_examples_for 'keystone user/tenant/service/role/endpoint resources using v2 API' do |auth_creds|
      it 'should find users in the default domain' do
        shell("openstack #{auth_creds} --os-auth-url http://127.0.0.1:5000/v2.0 --os-identity-api-version 2 user list") do |r|
          expect(r.stdout).to match(/admin/)
          expect(r.stderr).to be_empty
        end
      end
      it 'should find tenants in the default domain' do
        shell("openstack #{auth_creds} --os-auth-url http://127.0.0.1:5000/v2.0 --os-identity-api-version 2 project list") do |r|
          expect(r.stdout).to match(/openstack/)
          expect(r.stderr).to be_empty
        end
      end
      it 'should find beaker service' do
        shell("openstack #{auth_creds} --os-auth-url http://127.0.0.1:5000/v2.0 --os-identity-api-version 2 service list") do |r|
          expect(r.stdout).to match(/beaker/)
          expect(r.stderr).to be_empty
        end
      end
      it 'should find admin role' do
        shell("openstack #{auth_creds} --os-auth-url http://127.0.0.1:5000/v2.0 --os-identity-api-version 2 role list") do |r|
          expect(r.stdout).to match(/admin/)
          expect(r.stderr).to be_empty
        end
      end
      it 'should find beaker endpoints' do
        shell("openstack #{auth_creds} --os-auth-url http://127.0.0.1:5000/v2.0 --os-identity-api-version 2 endpoint list --long") do |r|
          expect(r.stdout).to match(/1234/)
          expect(r.stderr).to be_empty
        end
      end
    end
    shared_examples_for 'keystone user/tenant/service/role/endpoint resources using v3 API' do |auth_creds|
      it 'should find beaker user' do
        shell("openstack #{auth_creds} --os-auth-url http://127.0.0.1:5000/v3 --os-identity-api-version 3 user list") do |r|
          expect(r.stdout).to match(/beaker/)
          expect(r.stderr).to be_empty
        end
      end
      it 'should find services tenant' do
        shell("openstack #{auth_creds} --os-auth-url http://127.0.0.1:5000/v3 --os-identity-api-version 3 project list") do |r|
          expect(r.stdout).to match(/services/)
          expect(r.stderr).to be_empty
        end
      end
      it 'should find beaker service' do
        shell("openstack #{auth_creds} --os-auth-url http://127.0.0.1:5000/v3 --os-identity-api-version 3 service list") do |r|
          expect(r.stdout).to match(/beaker/)
          expect(r.stderr).to be_empty
        end
      end
      it 'should find admin role' do
        shell("openstack #{auth_creds} --os-auth-url http://127.0.0.1:5000/v3 --os-identity-api-version 3 role list") do |r|
          expect(r.stdout).to match(/admin/)
          expect(r.stderr).to be_empty
        end
      end
      it 'should find beaker endpoints' do
        shell("openstack #{auth_creds} --os-auth-url http://127.0.0.1:5000/v3 --os-identity-api-version 3 endpoint list") do |r|
          expect(r.stdout).to match(/1234/)
          expect(r.stderr).to be_empty
        end
      end
    end
    describe 'with v2 admin with v2 credentials' do
      include_examples 'keystone user/tenant/service/role/endpoint resources using v2 API',
                       '--os-username admin --os-password a_big_secret --os-project-name openstack'
    end
    describe 'with v2 service with v2 credentials' do
      include_examples 'keystone user/tenant/service/role/endpoint resources using v2 API',
                       '--os-username beaker-ci --os-password secret --os-project-name services'
    end
    describe 'with v2 admin with v3 credentials' do
      include_examples 'keystone user/tenant/service/role/endpoint resources using v3 API',
                       '--os-username admin --os-password a_big_secret --os-project-name openstack --os-user-domain-name Default --os-project-domain-name Default'
    end
    describe "with v2 service with v3 credentials" do
      include_examples 'keystone user/tenant/service/role/endpoint resources using v3 API',
                       '--os-username beaker-ci --os-password secret --os-project-name services --os-user-domain-name Default --os-project-domain-name Default'
    end
    describe 'with v3 admin with v3 credentials' do
      include_examples 'keystone user/tenant/service/role/endpoint resources using v3 API',
                       '--os-username adminv3 --os-password a_big_secret --os-project-name openstackv3 --os-user-domain-name admin_domain --os-project-domain-name admin_domain'
    end
    describe "with v3 service with v3 credentials" do
      include_examples 'keystone user/tenant/service/role/endpoint resources using v3 API',
                       '--os-username beaker-civ3 --os-password secret --os-project-name servicesv3 --os-user-domain-name service_domain --os-project-domain-name service_domain'
    end
  end
  describe 'composite namevar quick test' do
    context 'similar resources different naming' do
      let(:pp) do
        <<-EOM
        keystone_tenant { 'openstackv3':
          ensure      => present,
          enabled     => true,
          description => 'admin tenant',
          domain      => 'admin_domain'
        }
        keystone_user { 'adminv3::useless_when_the_domain_is_set':
          ensure      => present,
          enabled     => true,
          email       => 'test@example.tld',
          password    => 'a_big_secret',
          domain      => 'admin_domain'
        }
        keystone_user_role { 'adminv3::admin_domain@openstackv3::admin_domain':
          ensure         => present,
          roles          => ['admin'],
        }
        EOM
      end
      it 'should not do any modification' do
        apply_manifest(pp, :catch_changes => true)
      end
    end
  end

  describe 'composite namevar for keystone_service and keystone_endpoint' do
    let(:pp) do
      <<-EOM
      keystone_service { 'service_1::type_1': ensure => present }
      keystone_service { 'service_1': type => 'type_2', ensure => present }
      keystone_endpoint { 'RegionOne/service_1::type_2':
        ensure => present,
        public_url => 'http://public_service1_type2',
        internal_url => 'http://internal_service1_type2',
        admin_url => 'http://admin_service1_type2'
      }
      keystone_endpoint { 'service_1':
        ensure => present,
        region => 'RegionOne',
        type => 'type_1',
        public_url   => 'http://public_url/',
        internal_url => 'http://public_url/',
        admin_url    => 'http://public_url/'
      }
      EOM
    end
    it 'should be possible to create two services different only by their type' do
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
    describe 'puppet service are created' do
      it 'for service' do
        shell('puppet resource keystone_service') do |result|
          expect(result.stdout)
            .to include_regexp([/keystone_service { 'service_1::type_1':/,
                                /keystone_service { 'service_1::type_2':/])
        end
      end
    end
    describe 'puppet endpoints are created' do
      it 'for service' do
        shell('puppet resource keystone_endpoint') do |result|
          expect(result.stdout)
            .to include_regexp([/keystone_endpoint { 'RegionOne\/service_1::type_1':/,
                                /keystone_endpoint { 'RegionOne\/service_1::type_2':/])
        end
      end
    end
  end
end
