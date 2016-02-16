require 'spec_helper'

describe 'gnocchi::db::sync' do

  shared_examples_for 'gnocchi-dbsync' do

    it 'runs gnocchi-manage db_sync' do
      is_expected.to contain_exec('gnocchi-db-sync').with(
        :command     => 'gnocchi-upgrade --config-file /etc/gnocchi/gnocchi.conf',
        :path        => '/usr/bin',
        :user        => 'gnocchi',
        :refreshonly => 'true',
        :logoutput   => 'on_failure'
      )
    end

  end


  context 'on a RedHat osfamily' do
    let :facts do
      {
        :osfamily                 => 'RedHat',
        :operatingsystemrelease   => '7.0',
      }
    end

    it_configures 'gnocchi-dbsync'
  end

  context 'on a Debian osfamily' do
    let :facts do
      {
        :operatingsystemrelease => '7.8',
        :operatingsystem        => 'Debian',
        :osfamily               => 'Debian',
      }
    end

    it_configures 'gnocchi-dbsync'
  end

end
