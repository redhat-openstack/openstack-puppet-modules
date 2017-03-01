require 'spec_helper'

describe 'aodh::api' do

  let :pre_condition do
    "class { 'aodh': }
     include ::aodh::db"
  end

  let :params do
    { :enabled           => true,
      :manage_service    => true,
      :keystone_password => 'aodh-passw0rd',
      :keystone_tenant   => 'services',
      :keystone_user     => 'aodh',
      :package_ensure    => 'latest',
      :port              => '8777',
      :host              => '0.0.0.0',
    }
  end

  shared_examples_for 'aodh-api' do

    context 'without required parameter keystone_password' do
      before { params.delete(:keystone_password) }
      it { expect { is_expected.to raise_error(Puppet::Error) } }
    end

    it { is_expected.to contain_class('aodh::params') }
    it { is_expected.to contain_class('aodh::policy') }

    it 'installs aodh-api package' do
      is_expected.to contain_package('aodh-api').with(
        :ensure => 'latest',
        :name   => platform_params[:api_package_name],
        :tag    => ['openstack', 'aodh-package'],
      )
    end

    it 'configures keystone authentication middleware' do
      is_expected.to contain_aodh_config('keystone_authtoken/admin_tenant_name').with_value( params[:keystone_tenant] )
      is_expected.to contain_aodh_config('keystone_authtoken/admin_user').with_value( params[:keystone_user] )
      is_expected.to contain_aodh_config('keystone_authtoken/admin_password').with_value( params[:keystone_password] )
      is_expected.to contain_aodh_config('keystone_authtoken/admin_password').with_value( params[:keystone_password] ).with_secret(true)
      is_expected.to contain_aodh_config('api/host').with_value( params[:host] )
      is_expected.to contain_aodh_config('api/port').with_value( params[:port] )
    end

    [{:enabled => true}, {:enabled => false}].each do |param_hash|
      context "when service should be #{param_hash[:enabled] ? 'enabled' : 'disabled'}" do
        before do
          params.merge!(param_hash)
        end

        it 'configures aodh-api service' do
          is_expected.to contain_service('aodh-api').with(
            :ensure     => (params[:manage_service] && params[:enabled]) ? 'running' : 'stopped',
            :name       => platform_params[:api_service_name],
            :enable     => params[:enabled],
            :hasstatus  => true,
            :hasrestart => true,
            :require    => 'Class[Aodh::Db]',
            :tag        => 'aodh-service',
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

      it 'configures aodh-api service' do
        is_expected.to contain_service('aodh-api').with(
          :ensure     => nil,
          :name       => platform_params[:api_service_name],
          :enable     => false,
          :hasstatus  => true,
          :hasrestart => true,
          :tag        => 'aodh-service',
        )
      end
    end

    context 'when running aodh-api in wsgi' do
      before do
        params.merge!({ :service_name   => 'httpd' })
      end

      let :pre_condition do
        "include ::apache
         include ::aodh::db
         class { 'aodh': }"
      end

      it 'configures aodh-api service with Apache' do
        is_expected.to contain_service('aodh-api').with(
          :ensure     => 'stopped',
          :name       => platform_params[:api_service_name],
          :enable     => false,
          :tag        => 'aodh-service',
        )
      end
    end

    context 'when service_name is not valid' do
      before do
        params.merge!({ :service_name   => 'foobar' })
      end

      let :pre_condition do
        "include ::apache
         include ::aodh::db
         class { 'aodh': }"
      end

      it_raises 'a Puppet::Error', /Invalid service_name/
    end
  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily               => 'Debian',
        :operatingsystem        => 'Debian',
        :operatingsystemrelease => '8.0',
        :concat_basedir         => '/var/lib/puppet/concat',
        :fqdn                   => 'some.host.tld',
        :processorcount         => 2 }
    end

    let :platform_params do
      { :api_package_name => 'aodh-api',
        :api_service_name => 'aodh-api' }
    end

    it_configures 'aodh-api'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily               => 'RedHat',
        :operatingsystem        => 'RedHat',
        :operatingsystemrelease => '7.1',
        :fqdn                   => 'some.host.tld',
        :concat_basedir         => '/var/lib/puppet/concat',
        :processorcount         => 2 }
    end

    let :platform_params do
      { :api_package_name => 'openstack-aodh-api',
        :api_service_name => 'openstack-aodh-api' }
    end

    it_configures 'aodh-api'
  end

  describe 'with custom auth_uri' do
    let :facts do
      { :osfamily => 'RedHat' }
    end
    before do
      params.merge!({
        :keystone_auth_uri => 'https://foo.bar:1234/',
      })
    end
    it 'should configure custom auth_uri correctly' do
      is_expected.to contain_aodh_config('keystone_authtoken/auth_uri').with_value( 'https://foo.bar:1234/' )
    end
  end

  describe "with custom keystone identity_uri" do
    let :facts do
      { :osfamily => 'RedHat' }
    end
    before do
      params.merge!({ 
        :keystone_identity_uri => 'https://foo.bar:1234/',
      })
    end
    it 'configures identity_uri' do
      is_expected.to contain_aodh_config('keystone_authtoken/identity_uri').with_value("https://foo.bar:1234/");
    end
  end

  describe "with custom keystone identity_uri and auth_uri" do
    let :facts do
      { :osfamily => 'RedHat' }
    end
    before do
      params.merge!({ 
        :keystone_identity_uri => 'https://foo.bar:35357/',
        :keystone_auth_uri => 'https://foo.bar:5000/v2.0/',
      })
    end
    it 'configures identity_uri and auth_uri but deprecates old auth settings' do
      is_expected.to contain_aodh_config('keystone_authtoken/identity_uri').with_value("https://foo.bar:35357/");
      is_expected.to contain_aodh_config('keystone_authtoken/auth_uri').with_value("https://foo.bar:5000/v2.0/");
    end
  end

end
