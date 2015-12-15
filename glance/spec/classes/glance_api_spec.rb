require 'spec_helper'

describe 'glance::api' do

  let :facts do
    @default_facts.merge({
     :osfamily       => 'Debian',
     :processorcount => '7',
    })
  end

  let :default_params do
    {
      :verbose                  => false,
      :debug                    => false,
      :use_stderr               => true,
      :bind_host                => '0.0.0.0',
      :bind_port                => '9292',
      :registry_host            => '0.0.0.0',
      :registry_port            => '9191',
      :registry_client_protocol => 'http',
      :log_file                 => '/var/log/glance/api.log',
      :log_dir                  => '/var/log/glance',
      :auth_type                => 'keystone',
      :auth_region              => 'RegionOne',
      :enabled                  => true,
      :manage_service           => true,
      :backlog                  => '4096',
      :workers                  => '7',
      :auth_host                => '127.0.0.1',
      :auth_port                => '35357',
      :auth_protocol            => 'http',
      :keystone_tenant          => 'services',
      :keystone_user            => 'glance',
      :keystone_password        => 'ChangeMe',
      :token_cache_time         => '<SERVICE DEFAULT>',
      :show_image_direct_url    => false,
      :purge_config             => false,
      :known_stores             => false,
      :delayed_delete           => '<SERVICE DEFAULT>',
      :scrub_time               => '<SERVICE DEFAULT>',
      :image_cache_dir          => '/var/lib/glance/image-cache',
      :image_cache_stall_time   => '<SERVICE DEFAULT>',
      :image_cache_max_size     => '<SERVICE DEFAULT>',
      :os_region_name           => 'RegionOne',
      :signing_dir              => '<SERVICE DEFAULT>',
      :pipeline                 => 'keystone',
    }
  end

  [{:keystone_password => 'ChangeMe'},
   {
      :verbose                  => true,
      :debug                    => true,
      :bind_host                => '127.0.0.1',
      :bind_port                => '9222',
      :registry_host            => '127.0.0.1',
      :registry_port            => '9111',
      :registry_client_protocol => 'https',
      :auth_type                => 'not_keystone',
      :auth_region              => 'RegionOne2',
      :enabled                  => false,
      :backlog                  => '4095',
      :workers                  => '5',
      :auth_host                => '127.0.0.2',
      :auth_port                => '35358',
      :auth_protocol            => 'https',
      :keystone_tenant          => 'admin2',
      :keystone_user            => 'admin2',
      :keystone_password        => 'ChangeMe2',
      :token_cache_time         => '300',
      :show_image_direct_url    => true,
      :delayed_delete           => 'true',
      :scrub_time               => '10',
      :image_cache_dir          => '/tmp/glance',
      :image_cache_stall_time   => '10',
      :image_cache_max_size     => '10737418240',
      :os_region_name           => 'RegionOne2',
      :signing_dir              => '/path/to/dir',
      :pipeline                 => 'keystone2',
    }
  ].each do |param_set|

    describe "when #{param_set == {:keystone_password => 'ChangeMe'} ? "using default" : "specifying"} class parameters" do

      let :param_hash do
        default_params.merge(param_set)
      end

      let :params do
        param_set
      end

      it { is_expected.to contain_class 'glance' }
      it { is_expected.to contain_class 'glance::policy' }
      it { is_expected.to contain_class 'glance::api::logging' }
      it { is_expected.to contain_class 'glance::api::db' }

      it { is_expected.to contain_service('glance-api').with(
        'ensure'     => (param_hash[:manage_service] && param_hash[:enabled]) ? 'running': 'stopped',
        'enable'     => param_hash[:enabled],
        'hasstatus'  => true,
        'hasrestart' => true,
        'tag'        => 'glance-service',
      ) }

      it { is_expected.to_not contain_exec('validate_nova_api') }
      it { is_expected.to contain_glance_api_config("paste_deploy/flavor").with_value(param_hash[:pipeline]) }

      it 'is_expected.to lay down default api config' do
        [
          'use_stderr',
          'bind_host',
          'bind_port',
          'registry_host',
          'registry_port',
          'registry_client_protocol',
          'show_image_direct_url',
          'delayed_delete',
          'scrub_time',
          'image_cache_dir',
          'auth_region'
        ].each do |config|
          is_expected.to contain_glance_api_config("DEFAULT/#{config}").with_value(param_hash[config.intern])
        end
      end

      it 'is_expected.to lay down default cache config' do
        [
          'registry_host',
          'registry_port',
          'image_cache_stall_time',
          'image_cache_max_size',
        ].each do |config|
          is_expected.to contain_glance_cache_config("DEFAULT/#{config}").with_value(param_hash[config.intern])
        end
      end

      it 'is_expected.to lay down default glance_store api and cache config' do
        [
          'os_region_name',
        ].each do |config|
          is_expected.to contain_glance_cache_config("glance_store/#{config}").with_value(param_hash[config.intern])
          is_expected.to contain_glance_api_config("glance_store/#{config}").with_value(param_hash[config.intern])
        end
      end

      it 'is_expected.to have no ssl options' do
        is_expected.to contain_glance_api_config('DEFAULT/ca_file').with_ensure('absent')
        is_expected.to contain_glance_api_config('DEFAULT/cert_file').with_ensure('absent')
        is_expected.to contain_glance_api_config('DEFAULT/key_file').with_ensure('absent')
      end

      it 'is_expected.to lay down default auth config' do
        [
          'auth_host',
          'auth_port',
          'auth_protocol'
        ].each do |config|
          is_expected.to contain_glance_api_config("keystone_authtoken/#{config}").with_value(param_hash[config.intern])
        end
      end
      it { is_expected.to contain_glance_api_config('keystone_authtoken/auth_admin_prefix').with_ensure('absent') }

      it 'is_expected.to configure itself for keystone if that is the auth_type' do
        if params[:auth_type] == 'keystone'
          is_expected.to contain('paste_deploy/flavor').with_value('keystone+cachemanagement')

          ['admin_tenant_name', 'admin_user', 'admin_password', 'token_cache_time', 'signing_dir'].each do |config|
            is_expected.to contain_glance_api_config("keystone_authtoken/#{config}").with_value(param_hash[config.intern])
          end
          is_expected.to contain_glance_api_config('keystone_authtoken/admin_password').with_value(param_hash[:keystone_password]).with_secret(true)

          ['admin_tenant_name', 'admin_user', 'admin_password'].each do |config|
            is_expected.to contain_glance_cache_config("keystone_authtoken/#{config}").with_value(param_hash[config.intern])
          end
          is_expected.to contain_glance_cache_config('keystone_authtoken/admin_password').with_value(param_hash[:keystone_password]).with_secret(true)
        end
      end
    end

  end

  describe 'with disabled service managing' do
    let :params do
      {
        :keystone_password => 'ChangeMe',
        :manage_service => false,
        :enabled        => false,
      }
    end

    it { is_expected.to contain_service('glance-api').with(
        'ensure'     => nil,
        'enable'     => false,
        'hasstatus'  => true,
        'hasrestart' => true,
        'tag'        => 'glance-service',
      ) }
  end

  describe 'with overridden pipeline' do
    let :params do
      {
        :keystone_password => 'ChangeMe',
        :pipeline          => 'something',
      }
    end

    it { is_expected.to contain_glance_api_config('paste_deploy/flavor').with_value('something') }
  end

  describe 'with blank pipeline' do
    let :params do
      {
        :keystone_password => 'ChangeMe',
        :pipeline          => '',
      }
    end

    it { is_expected.to contain_glance_api_config('paste_deploy/flavor').with_ensure('absent') }
  end

  [
    'keystone/',
    'keystone+',
    '+keystone',
    'keystone+cachemanagement+',
    '+'
  ].each do |pipeline|
    describe "with pipeline incorrect value #{pipeline}" do
      let :params do
        {
          :keystone_password => 'ChangeMe',
          :pipeline          => pipeline
        }
      end

      it { expect { is_expected.to contain_glance_api_config('filter:paste_deploy/flavor') }.to\
        raise_error(Puppet::Error, /validate_re\(\): .* does not match/) }
    end
  end

  describe 'with overriden auth_admin_prefix' do
    let :params do
      {
        :keystone_password => 'ChangeMe',
        :auth_admin_prefix => '/keystone/main'
      }
    end

    it { is_expected.to contain_glance_api_config('keystone_authtoken/auth_admin_prefix').with_value('/keystone/main') }
  end

  [
    '/keystone/',
    'keystone/',
    'keystone',
    '/keystone/admin/',
    'keystone/admin/',
    'keystone/admin'
  ].each do |auth_admin_prefix|
    describe "with auth_admin_prefix_containing incorrect value #{auth_admin_prefix}" do
      let :params do
        {
          :keystone_password => 'ChangeMe',
          :auth_admin_prefix => auth_admin_prefix
        }
      end

      it { expect { is_expected.to contain_glance_api_config('filter:authtoken/auth_admin_prefix') }.to\
        raise_error(Puppet::Error, /validate_re\(\): "#{auth_admin_prefix}" does not match/) }
    end
  end

  describe 'with ssl options' do
    let :params do
      default_params.merge({
        :ca_file     => '/tmp/ca_file',
        :cert_file   => '/tmp/cert_file',
        :key_file    => '/tmp/key_file'
      })
    end

    context 'with ssl options' do
      it { is_expected.to contain_glance_api_config('DEFAULT/ca_file').with_value('/tmp/ca_file') }
      it { is_expected.to contain_glance_api_config('DEFAULT/cert_file').with_value('/tmp/cert_file') }
      it { is_expected.to contain_glance_api_config('DEFAULT/key_file').with_value('/tmp/key_file') }
    end
  end
  describe 'with known_stores by default' do
    let :params do
      default_params
    end

    it { is_expected.to_not contain_glance_api_config('glance_store/stores').with_value('false') }
  end

  describe 'with known_stores override' do
    let :params do
      default_params.merge({
        :known_stores   => ['glance.store.filesystem.Store','glance.store.http.Store'],
      })
    end

    it { is_expected.to contain_glance_api_config('glance_store/stores').with_value("glance.store.filesystem.Store,glance.store.http.Store") }
  end

  describe 'while validating the service with default command' do
    let :params do
      default_params.merge({
        :validate => true,
      })
    end
    it { is_expected.to contain_exec('execute glance-api validation').with(
      :path        => '/usr/bin:/bin:/usr/sbin:/sbin',
      :provider    => 'shell',
      :tries       => '10',
      :try_sleep   => '2',
      :command     => 'glance --os-auth-url http://localhost:5000/v2.0 --os-tenant-name services --os-username glance --os-password ChangeMe image-list',
    )}

    it { is_expected.to contain_anchor('create glance-api anchor').with(
      :require => 'Exec[execute glance-api validation]',
    )}
  end

  describe 'while validating the service with custom command' do
    let :params do
      default_params.merge({
        :validate            => true,
        :validation_options  => { 'glance-api' => { 'command' => 'my-script' } }
      })
    end
    it { is_expected.to contain_exec('execute glance-api validation').with(
      :path        => '/usr/bin:/bin:/usr/sbin:/sbin',
      :provider    => 'shell',
      :tries       => '10',
      :try_sleep   => '2',
      :command     => 'my-script',
    )}

    it { is_expected.to contain_anchor('create glance-api anchor').with(
      :require => 'Exec[execute glance-api validation]',
    )}
  end

  describe 'with identity and auth settings' do
    let :params do
      {
        :keystone_password => 'ChangeMe',
      }
    end
    context 'with custom keystone identity_uri' do
      let :params do
        default_params.merge!({
          :identity_uri => 'https://foo.bar:1234/',
        })
      end
      it 'configures identity_uri' do
        is_expected.to contain_glance_api_config('keystone_authtoken/identity_uri').with_value("https://foo.bar:1234/");
        # since only identity_uri is set the deprecated auth parameters is_expected.to
        # still get set in case they are still in use
        is_expected.to contain_glance_api_config('keystone_authtoken/auth_host').with_value('127.0.0.1');
        is_expected.to contain_glance_api_config('keystone_authtoken/auth_port').with_value('35357');
        is_expected.to contain_glance_api_config('keystone_authtoken/auth_protocol').with_value('http');
      end
    end

    context 'with custom keystone identity_uri and auth_uri' do
      let :params do
        default_params.merge!({
          :identity_uri => 'https://foo.bar:35357/',
          :auth_uri => 'https://foo.bar:5000/v2.0/',
        })
      end
      it 'configures identity_uri' do
        is_expected.to contain_glance_api_config('keystone_authtoken/identity_uri').with_value("https://foo.bar:35357/");
        is_expected.to contain_glance_api_config('keystone_authtoken/auth_uri').with_value("https://foo.bar:5000/v2.0/");
        is_expected.to contain_glance_api_config('keystone_authtoken/auth_host').with_ensure('absent')
        is_expected.to contain_glance_api_config('keystone_authtoken/auth_port').with_ensure('absent')
        is_expected.to contain_glance_api_config('keystone_authtoken/auth_protocol').with_ensure('absent')
        is_expected.to contain_glance_api_config('keystone_authtoken/auth_admin_prefix').with_ensure('absent')
      end
    end
  end


  describe 'on Debian platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily       => 'Debian',
      })
    end
    let(:params) { default_params }

    # We only test this on Debian platforms, since on RedHat there isn't a
    # separate package for glance API.
    ['present', 'latest'].each do |package_ensure|
      context "with package_ensure '#{package_ensure}'" do
        let(:params) { default_params.merge({ :package_ensure => package_ensure }) }
        it { is_expected.to contain_package('glance-api').with(
            :ensure => package_ensure,
            :tag    => ['openstack', 'glance-package']
        )}
      end
    end
  end

  describe 'on RedHat platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily               => 'RedHat',
        :operatingsystemrelease => '7',
      })
    end
    let(:params) { default_params }

    it { is_expected.to contain_package('openstack-glance').with(
        :tag => ['openstack', 'glance-package'],
    )}
  end

  describe 'on unknown platforms' do
    let :facts do
      { :osfamily => 'unknown' }
    end
    let(:params) { default_params }

    it_raises 'a Puppet::Error', /module glance only support osfamily RedHat and Debian/
  end

end
