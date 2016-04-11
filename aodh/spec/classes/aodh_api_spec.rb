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
      :port              => '8042',
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

    context 'with sync_db set to true' do
      before do
        params.merge!(
          :sync_db => true)
      end
      it { is_expected.to contain_class('aodh::db::sync') }
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

    context "with custom keystone identity_uri and auth_uri" do
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

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts({
          :fqdn           => 'some.host.tld',
          :processorcount => 2,
          :concat_basedir => '/var/lib/puppet/concat'
        }))
      end

      let(:platform_params) do
        case facts[:osfamily]
        when 'Debian'
          { :api_package_name => 'aodh-api',
            :api_service_name => 'aodh-api' }
        when 'RedHat'
          { :api_package_name => 'openstack-aodh-api',
            :api_service_name => 'openstack-aodh-api' }
        end
      end
      it_configures 'aodh-api'
    end
  end

end
