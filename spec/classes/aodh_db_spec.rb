require 'spec_helper'

describe 'aodh::db' do

  shared_examples 'aodh::db' do

    context 'with default parameters' do

      it { is_expected.to contain_class('aodh::params') }
      it { is_expected.to contain_aodh_config('database/connection').with_value('sqlite:////var/lib/aodh/aodh.sqlite') }
      it { is_expected.to contain_aodh_config('database/idle_timeout').with_value('3600') }
      it { is_expected.to contain_aodh_config('database/min_pool_size').with_value('1') }
      it { is_expected.to contain_aodh_config('database/max_retries').with_value('10') }
      it { is_expected.to contain_aodh_config('database/retry_interval').with_value('10') }

    end

    context 'with specific parameters' do
      let :params do
        { :database_connection     => 'mysql://aodh:aodh@localhost/aodh',
          :database_idle_timeout   => '3601',
          :database_min_pool_size  => '2',
          :database_max_retries    => '11',
          :database_retry_interval => '11',
        }
      end

      it { is_expected.to contain_class('aodh::params') }
      it { is_expected.to contain_aodh_config('database/connection').with_value('mysql://aodh:aodh@localhost/aodh').with_secret(true) }
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


    context 'with incorrect database_connection string' do
      let :params do
        { :database_connection     => 'redis://aodh:aodh@localhost/aodh', }
      end

      it_raises 'a Puppet::Error', /validate_re/
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian',
        :operatingsystem => 'Debian',
        :operatingsystemrelease => 'jessie',
      }
    end

    it_configures 'aodh::db'

    context 'with sqlite backend' do
      let :params do
        { :database_connection     => 'sqlite:///var/lib/aodh/aodh.sqlite', }
      end

      it 'install the proper backend package' do
        is_expected.to contain_package('aodh-backend-package').with(
          :ensure => 'present',
          :name   => 'python-pysqlite2',
          :tag    => 'openstack'
        )
      end

    end
  end

  context 'on Redhat platforms' do
    let :facts do
      { :osfamily => 'RedHat',
        :operatingsystemrelease => '7.1',
      }
    end

    it_configures 'aodh::db'
  end

end

