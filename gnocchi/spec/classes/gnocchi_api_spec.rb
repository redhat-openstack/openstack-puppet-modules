#
# Unit tests for gnocchi::api
#
require 'spec_helper'

describe 'gnocchi::api' do

  let :params do
    { :keystone_password     => 'passw0rd',
      :keystone_user         => 'gnocchi',
      :identity_uri          => 'https://identity.os.net:5000',
      :keystone_tenant       => '_services_',
    }
  end

  shared_examples 'gnocchi-api' do

    context 'with default parameters' do

      it 'installs gnocchi-api package and service' do
        should contain_service('gnocchi-api').with(
          :name      => platform_params[:api_service_name],
          :ensure    => 'running',
          :hasstatus => true,
          :enable    => true
        )
        should contain_package('gnocchi-api').with(
          :name   => platform_params[:api_package_name],
          :ensure => 'present',
          :notify => 'Service[gnocchi-api]'
        )
      end

      it 'configures gnocchi-api with default parameters' do
        should contain_gnocchi_config('DEFAULT/verbose').with_value(false)
        should contain_gnocchi_config('DEFAULT/debug').with_value(false)
        should contain_gnocchi_config('keystone_authtoken/identity_uri').with_value(params[:identity_uri])
        should contain_gnocchi_config('keystone_authtoken/admin_tenant_name').with_value(params[:keystone_tenant])
        should contain_gnocchi_config('keystone_authtoken/admin_user').with_value(params[:keystone_user])
        should contain_gnocchi_config('keystone_authtoken/admin_password').with_value(params[:keystone_password])
        should contain_gnocchi_config('keystone_authtoken/admin_password').with_value(params[:keystone_password]).with_secret(true)
      end

      context 'when using MySQL' do
        let :pre_condition do
          "class { 'gnocchi':
             database_connection   => 'mysql://gnocchi:pass@10.0.0.1/gnocchi'}"
        end
        it 'configures gnocchi-api with RabbitMQ' do
          should contain_gnocchi_config('database/connection').with_value('mysql://gnocchi:pass@10.0.0.1/gnocchi')
          should contain_gnocchi_config('database/connection').with_value('mysql://gnocchi:pass@10.0.0.1/gnocchi').with_secret(true)
        end
      end
    end
  end

  context 'on Debian platforms' do
    let :facts do
      {
        :osfamily       => 'Debian'
      }
    end

    let :platform_params do
      { :api_package_name => 'gnocchi-api',
        :api_service_name => 'gnocchi-api' }
    end

    it_configures 'gnocchi-api'
  end

  context 'on RedHat platforms' do
    let :facts do
      {
        :osfamily       => 'RedHat'
      }
    end

    let :platform_params do
      { :api_package_name => 'openstack-gnocchi-api',
        :api_service_name => 'openstack-gnocchi-api' }
    end

    it_configures 'gnocchi-api'
  end

end
