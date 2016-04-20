require 'spec_helper'

describe 'aodh::db' do

  shared_examples 'aodh::db' do

    context 'with default parameters' do

      it { is_expected.to contain_aodh_config('database/connection').with_value('sqlite:////var/lib/aodh/aodh.sqlite') }
      it { is_expected.to contain_aodh_config('database/idle_timeout').with_value('3600') }
      it { is_expected.to contain_aodh_config('database/min_pool_size').with_value('1') }
      it { is_expected.to contain_aodh_config('database/max_retries').with_value('10') }
      it { is_expected.to contain_aodh_config('database/retry_interval').with_value('10') }

    end

    context 'with specific parameters' do
      let :params do
        { :database_connection     => 'mysql+pymysql://aodh:aodh@localhost/aodh',
          :database_idle_timeout   => '3601',
          :database_min_pool_size  => '2',
          :database_max_retries    => '11',
          :database_retry_interval => '11',
        }
      end

      it { is_expected.to contain_aodh_config('database/connection').with_value('mysql+pymysql://aodh:aodh@localhost/aodh').with_secret(true) }
      it { is_expected.to contain_aodh_config('database/idle_timeout').with_value('3601') }
      it { is_expected.to contain_aodh_config('database/min_pool_size').with_value('2') }
      it { is_expected.to contain_aodh_config('database/max_retries').with_value('11') }
      it { is_expected.to contain_aodh_config('database/retry_interval').with_value('11') }

    end

    context 'with postgresql backend' do
      let :params do
        { :database_connection     => 'postgresql://localhost:1234/aodh', }
      end

      it 'install the proper backend package' do
        is_expected.to contain_package('python-psycopg2').with(:ensure => 'present')
      end

    end

    context 'with MySQL-python library as backend package' do
      let :params do
        { :database_connection     => 'mysql://aodh:aodh@localhost/aodh', }
      end

      it { is_expected.to contain_package('python-mysqldb').with(:ensure => 'present') }
    end

    context 'with mongodb backend' do
      let :params do
        { :database_connection => 'mongodb://localhost:1234/aodh', }
      end

      it 'installs python-mongodb package' do
        is_expected.to contain_package('db_backend_package').with(
          :ensure => 'present',
          :name   => 'python-pymongo',
          :tag    => 'openstack'
        )
        is_expected.to contain_aodh_config('database/connection').with_value('mongodb://localhost:1234/aodh')
        is_expected.to contain_aodh_config('database/connection').with_value( params[:database_connection] ).with_secret(true)
      end

    end

    context 'with incorrect database_connection string' do
      let :params do
        { :database_connection     => 'redis://aodh:aodh@localhost/aodh', }
      end

      it_raises 'a Puppet::Error', /validate_re/
    end

    context 'with incorrect pymysql database_connection string' do
      let :params do
        { :database_connection     => 'foo+pymysql://aodh:aodh@localhost/aodh', }
      end

      it_raises 'a Puppet::Error', /validate_re/
    end
  end

  shared_examples_for 'aodh::db on Debian' do
    context 'with sqlite backend' do
      let :params do
        { :database_connection     => 'sqlite:///var/lib/aodh/aodh.sqlite', }
      end

      it 'install the proper backend package' do
        is_expected.to contain_package('db_backend_package').with(
          :ensure => 'present',
          :name   => 'python-pysqlite2',
          :tag    => 'openstack'
        )
      end
    end

    context 'using pymysql driver' do
      let :params do
        { :database_connection     => 'mysql+pymysql://aodh:aodh@localhost/aodh', }
      end

      it 'install the proper backend package' do
        is_expected.to contain_package('db_backend_package').with(
          :ensure => 'present',
          :name   => 'python-pymysql',
          :tag    => 'openstack'
        )
      end
    end
  end

  shared_examples_for 'aodh::db on RedHat' do
    context 'using pymysql driver' do
      let :params do
        { :database_connection     => 'mysql+pymysql://aodh:aodh@localhost/aodh', }
      end

      it { is_expected.not_to contain_package('db_backend_package') }
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      case facts[:osfamily]
      when 'Debian'
        it_configures 'aodh::db on Debian'
      when 'RedHat'
        it_configures 'aodh::db on RedHat'
      end
      it_configures 'aodh::db'
    end
  end
end

