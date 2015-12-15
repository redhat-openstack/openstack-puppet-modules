require 'spec_helper'

describe 'gnocchi::db' do

  shared_examples 'gnocchi::db' do

    context 'with default parameters' do
      it { is_expected.to contain_gnocchi_config('indexer/url').with_value('sqlite:////var/lib/gnocchi/gnocchi.sqlite').with_secret(true) }

      it 'installs packages' do
        is_expected.to contain_package('gnocchi-indexer-sqlalchemy').with(
          :name   => platform_params[:gnocchi_indexer_package],
          :ensure => 'present',
          :tag    => ['openstack', 'gnocchi-package']
        )
      end
    end

    context 'with specific parameters' do
      let :params do
        { :database_connection => 'mysql://gnocchi:gnocchi@localhost/gnocchi' }
      end

      it { is_expected.to contain_gnocchi_config('indexer/url').with_value('mysql://gnocchi:gnocchi@localhost/gnocchi').with_secret(true) }

    end

    context 'with postgresql backend' do
      let :params do
        { :database_connection     => 'postgresql://gnocchi:gnocchi@localhost/gnocchi', }
      end

      it 'install the proper backend package' do
        is_expected.to contain_package('python-psycopg2').with(:ensure => 'present')
      end

    end

    context 'with incorrect database_connection string' do
      let :params do
        { :database_connection     => 'redis://gnocchi:gnocchi@localhost/gnocchi', }
      end

      it_raises 'a Puppet::Error', /validate_re/
    end

  end

  context 'on Debian platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily               => 'Debian',
        :operatingsystem        => 'Debian',
        :operatingsystemrelease => 'jessie',
      })
    end

    let :platform_params do
      { :gnocchi_indexer_package => 'gnocchi-indexer-sqlalchemy' }
    end

    it_configures 'gnocchi::db'
  end

  context 'on Redhat platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily               => 'RedHat',
        :operatingsystemrelease => '7.1',
      })
    end

    let :platform_params do
      { :gnocchi_indexer_package => 'openstack-gnocchi-indexer-sqlalchemy' }
    end

    it_configures 'gnocchi::db'
  end

end
