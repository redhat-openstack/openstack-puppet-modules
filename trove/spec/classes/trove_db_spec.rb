require 'spec_helper'

describe 'trove::db' do

  shared_examples 'trove::db' do

    context 'with default parameters' do

      it { is_expected.to contain_trove_config('database/connection').with_value('sqlite:////var/lib/trove/trove.sqlite').with_secret(true) }
      it { is_expected.to contain_trove_config('database/idle_timeout').with_value('3600') }
      it { is_expected.to contain_trove_config('database/min_pool_size').with_value('1') }
      it { is_expected.to contain_trove_config('database/max_pool_size').with_value('10') }
      it { is_expected.to contain_trove_config('database/max_overflow').with_value('20') }
      it { is_expected.to contain_trove_config('database/max_retries').with_value('10') }
      it { is_expected.to contain_trove_config('database/retry_interval').with_value('10') }

    end

    context 'with specific parameters' do
      let :params do
        { :database_connection     => 'mysql://trove:trove@localhost/trove',
          :database_idle_timeout   => '3601',
          :database_min_pool_size  => '2',
          :database_max_pool_size  => '21',
          :database_max_retries    => '11',
          :database_max_overflow   => '21',
          :database_retry_interval => '11', }
      end

      it { is_expected.to contain_trove_config('database/connection').with_value('mysql://trove:trove@localhost/trove').with_secret(true) }
      it { is_expected.to contain_trove_config('database/idle_timeout').with_value('3601') }
      it { is_expected.to contain_trove_config('database/min_pool_size').with_value('2') }
      it { is_expected.to contain_trove_config('database/max_retries').with_value('11') }
      it { is_expected.to contain_trove_config('database/max_pool_size').with_value('21') }
      it { is_expected.to contain_trove_config('database/max_overflow').with_value('21') }
      it { is_expected.to contain_trove_config('database/retry_interval').with_value('11') }

    end

    context 'with postgresql backend' do
      let :params do
        { :database_connection     => 'postgresql://trove:trove@localhost/trove', }
      end

      it 'install the proper backend package' do
        is_expected.to contain_package('python-psycopg2').with(:ensure => 'present')
      end

    end

    context 'with incorrect database_connection string' do
      let :params do
        { :database_connection     => 'redis://trove:trove@localhost/trove', }
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

    it_configures 'trove::db'
  end

  context 'on Redhat platforms' do
    let :facts do
      { :osfamily => 'RedHat',
        :operatingsystemrelease => '7.1',
      }
    end

    it_configures 'trove::db'
  end

end
