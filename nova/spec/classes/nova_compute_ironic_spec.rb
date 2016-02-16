require 'spec_helper'

describe 'nova::compute::ironic' do

  shared_examples_for 'nova-compute-ironic' do

  context 'with default parameters' do
    it 'configures ironic in nova.conf' do
      is_expected.to contain_nova_config('ironic/admin_username').with_value('admin')
      is_expected.to contain_nova_config('ironic/admin_password').with_value('ironic')
      is_expected.to contain_nova_config('ironic/admin_url').with_value('http://127.0.0.1:35357/v2.0')
      is_expected.to contain_nova_config('ironic/admin_tenant_name').with_value('services')
      is_expected.to contain_nova_config('ironic/api_endpoint').with_value('http://127.0.0.1:6385/v1')
      is_expected.to contain_nova_config('DEFAULT/compute_driver').with_value('ironic.IronicDriver')
      is_expected.to contain_nova_config('DEFAULT/max_concurrent_builds').with_value('<SERVICE DEFAULT>')
    end
  end

  context 'with overridden parameters' do
    let :params do
      {
        :admin_username        => 'ironic',
        :admin_password        => 's3cr3t',
        :admin_url             => 'http://10.0.0.10:35357/v2.0',
        :admin_tenant_name     => 'services2',
        :api_endpoint          => 'http://10.0.0.10:6385/v1',
        :compute_driver        => 'ironic.FoobarDriver',
        :max_concurrent_builds => 15,
      }
    end

    it 'configures ironic in nova.conf' do
      is_expected.to contain_nova_config('ironic/admin_username').with_value('ironic')
      is_expected.to contain_nova_config('ironic/admin_password').with_value('s3cr3t')
      is_expected.to contain_nova_config('ironic/admin_url').with_value('http://10.0.0.10:35357/v2.0')
      is_expected.to contain_nova_config('ironic/admin_tenant_name').with_value('services2')
      is_expected.to contain_nova_config('ironic/api_endpoint').with_value('http://10.0.0.10:6385/v1')
      is_expected.to contain_nova_config('DEFAULT/compute_driver').with_value('ironic.FoobarDriver')
      is_expected.to contain_nova_config('DEFAULT/max_concurrent_builds').with_value(15)
    end
  end

  context 'with deprecated parameters' do

    let :params do
      {:admin_user   => 'ironic-user',
       :admin_passwd => 'ironic-s3cr3t'}
    end

    it 'configures ironic in nova.conf' do
      is_expected.to contain_nova_config('ironic/admin_username').with_value('ironic-user')
      is_expected.to contain_nova_config('ironic/admin_password').with_value('ironic-s3cr3t')
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
            {}
        when 'RedHat'
            {}
        end
      end
      it_configures 'nova-compute-ironic'
    end
  end
end
