require 'spec_helper'

describe 'gnocchi::api' do

  let :pre_condition do
    "class { 'gnocchi': }
     include ::gnocchi::db"
  end

  let :params do
    { :enabled           => true,
      :manage_service    => true,
      :keystone_password => 'gnocchi-passw0rd',
      :keystone_tenant   => 'services',
      :keystone_user     => 'gnocchi',
      :package_ensure    => 'latest',
      :port              => '8041',
      :max_limit         => '1000',
      :host              => '0.0.0.0',
    }
  end

  shared_examples_for 'gnocchi-api' do

    context 'without required parameter keystone_password' do
      before { params.delete(:keystone_password) }
      it { expect { is_expected.to raise_error(Puppet::Error) } }
    end

    it { is_expected.to contain_class('gnocchi::params') }
    it { is_expected.to contain_class('gnocchi::policy') }

    it 'installs gnocchi-api package' do
      is_expected.to contain_package('gnocchi-api').with(
        :ensure => 'latest',
        :name   => platform_params[:api_package_name],
        :tag    => ['openstack', 'gnocchi-package'],
      )
    end

    it 'configures keystone authentication middleware' do
      is_expected.to contain_gnocchi_config('keystone_authtoken/admin_tenant_name').with_value( params[:keystone_tenant] )
      is_expected.to contain_gnocchi_config('keystone_authtoken/admin_user').with_value( params[:keystone_user] )
      is_expected.to contain_gnocchi_config('keystone_authtoken/admin_password').with_value( params[:keystone_password] )
      is_expected.to contain_gnocchi_config('keystone_authtoken/admin_password').with_value( params[:keystone_password] ).with_secret(true)
      is_expected.to contain_gnocchi_config('api/host').with_value( params[:host] )
      is_expected.to contain_gnocchi_config('api/port').with_value( params[:port] )
      is_expected.to contain_gnocchi_config('api/max_limit').with_value( params[:max_limit] )
      is_expected.to contain_gnocchi_config('api/workers').with_value('2')
    end

    [{:enabled => true}, {:enabled => false}].each do |param_hash|
      context "when service should be #{param_hash[:enabled] ? 'enabled' : 'disabled'}" do
        before do
          params.merge!(param_hash)
        end

        it 'configures gnocchi-api service' do
          is_expected.to contain_service('gnocchi-api').with(
            :ensure     => (params[:manage_service] && params[:enabled]) ? 'running' : 'stopped',
            :name       => platform_params[:api_service_name],
            :enable     => params[:enabled],
            :hasstatus  => true,
            :hasrestart => true,
            :require    => 'Class[Gnocchi::Db]',
            :tag        => ['gnocchi-service', 'gnocchi-db-sync-service'],
          )
        end
      end
    end

    context 'with disabled service managing' do
      before do
        params.merge!({
          :manage_service => false,
          :enabled        => false })
      end

      it 'configures gnocchi-api service' do
        is_expected.to contain_service('gnocchi-api').with(
          :ensure     => nil,
          :name       => platform_params[:api_service_name],
          :enable     => false,
          :hasstatus  => true,
          :hasrestart => true,
          :tag        => ['gnocchi-service', 'gnocchi-db-sync-service'],
        )
      end
    end

    context 'when running gnocchi-api in wsgi' do
      before do
        params.merge!({ :service_name   => 'httpd' })
      end

      let :pre_condition do
        "include ::apache
         include ::gnocchi::db
         class { 'gnocchi': }"
      end

      it 'configures gnocchi-api service with Apache' do
        is_expected.to contain_service('gnocchi-api').with(
          :ensure     => 'stopped',
          :name       => platform_params[:api_service_name],
          :enable     => false,
          :tag        => ['gnocchi-service', 'gnocchi-db-sync-service'],
        )
      end
    end

    context 'when service_name is not valid' do
      before do
        params.merge!({ :service_name   => 'foobar' })
      end

      let :pre_condition do
        "include ::apache
         include ::gnocchi::db
         class { 'gnocchi': }"
      end

      it_raises 'a Puppet::Error', /Invalid service_name/
    end
  end

  context 'on Debian platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily               => 'Debian',
        :operatingsystem        => 'Debian',
        :operatingsystemrelease => '8.0',
        :concat_basedir         => '/var/lib/puppet/concat',
        :fqdn                   => 'some.host.tld',
        :processorcount         => 2,
      })
    end

    let :platform_params do
      { :api_package_name => 'gnocchi-api',
        :api_service_name => 'gnocchi-api' }
    end

    it_configures 'gnocchi-api'
  end

  context 'on RedHat platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily               => 'RedHat',
        :operatingsystem        => 'RedHat',
        :operatingsystemrelease => '7.1',
        :fqdn                   => 'some.host.tld',
        :concat_basedir         => '/var/lib/puppet/concat',
        :processorcount         => 2,
      })
    end

    let :platform_params do
      { :api_package_name => 'openstack-gnocchi-api',
        :api_service_name => 'openstack-gnocchi-api' }
    end

    it_configures 'gnocchi-api'
  end

  describe 'with custom auth_uri' do
    let :facts do
      @default_facts.merge({ :osfamily => 'RedHat' })
    end
    before do
      params.merge!({
        :keystone_auth_uri => 'https://foo.bar:1234/',
      })
    end
    it 'should configure custom auth_uri correctly' do
      is_expected.to contain_gnocchi_config('keystone_authtoken/auth_uri').with_value( 'https://foo.bar:1234/' )
    end
  end

  describe "with custom keystone identity_uri" do
    let :facts do
      @default_facts.merge({ :osfamily => 'RedHat' })
    end
    before do
      params.merge!({
        :keystone_identity_uri => 'https://foo.bar:1234/',
      })
    end
    it 'configures identity_uri' do
      is_expected.to contain_gnocchi_config('keystone_authtoken/identity_uri').with_value("https://foo.bar:1234/");
      is_expected.to contain_gnocchi_api_paste_ini('pipeline:main/pipeline').with_value('keystone_authtoken gnocchi');
    end
  end

  describe "with custom keystone identity_uri and auth_uri" do
    let :facts do
      @default_facts.merge({ :osfamily => 'RedHat' })
    end
    before do
      params.merge!({
        :keystone_identity_uri => 'https://foo.bar:35357/',
        :keystone_auth_uri => 'https://foo.bar:5000/v2.0/',
      })
    end
    it 'configures identity_uri and auth_uri but deprecates old auth settings' do
      is_expected.to contain_gnocchi_config('keystone_authtoken/identity_uri').with_value("https://foo.bar:35357/");
      is_expected.to contain_gnocchi_config('keystone_authtoken/auth_uri').with_value("https://foo.bar:5000/v2.0/");
      is_expected.to contain_gnocchi_api_paste_ini('pipeline:main/pipeline').with_value('keystone_authtoken gnocchi');
    end
  end

end
