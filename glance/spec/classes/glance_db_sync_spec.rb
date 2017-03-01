require 'spec_helper'

describe 'glance::db::sync' do

  shared_examples_for 'glance-dbsync' do

    it 'runs glance-manage db_sync' do
      is_expected.to contain_exec('glance-manage db_sync').with(
        :command     => 'glance-manage  db_sync',
        :path        => '/usr/bin',
        :user        => 'glance',
        :refreshonly => 'true',
        :logoutput   => 'on_failure'
      )
    end

    describe "overriding extra_params" do
      let :params do
        {
          :extra_params => '--config-file /etc/glance/glance.conf',
        }
      end

      it {is_expected.to contain_exec('glance-manage db_sync').with(
        :command     => 'glance-manage --config-file /etc/glance/glance.conf db_sync',
        :path        => '/usr/bin',
        :user        => 'glance',
        :refreshonly => 'true',
        :logoutput   => 'on_failure'
      )
      }
    end


  end

  context 'on a RedHat osfamily' do
    let :facts do
      @default_facts.merge({
        :osfamily                 => 'RedHat',
        :operatingsystemrelease   => '7.0',
        :concat_basedir => '/var/lib/puppet/concat'
      })
    end

    it_configures 'glance-dbsync'
  end

  context 'on a Debian osfamily' do
    let :facts do
      @default_facts.merge({
        :operatingsystemrelease => '7.8',
        :operatingsystem        => 'Debian',
        :osfamily               => 'Debian',
        :concat_basedir => '/var/lib/puppet/concat'
      })
    end

    it_configures 'glance-dbsync'
  end

end
