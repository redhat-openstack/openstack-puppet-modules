require 'spec_helper'

describe 'gnocchi::db::sync' do

  shared_examples_for 'gnocchi-dbsync' do

    it 'runs gnocchi-manage db_sync' do
      is_expected.to contain_exec('gnocchi-db-sync').with(
        :command     => 'gnocchi-upgrade --config-file /etc/gnocchi/gnocchi.conf ',
        :path        => '/usr/bin',
        :user        => 'gnocchi',
        :refreshonly => 'true',
        :logoutput   => 'on_failure'
      )
    end
    describe "overriding extra_opts" do
        let :params do
            {
              :extra_opts => '--skip-storage',
            }
        end
        it { is_expected.to contain_exec('gnocchi-db-sync').with(
            :command     => 'gnocchi-upgrade --config-file /etc/gnocchi/gnocchi.conf --skip-storage',
            :path        => '/usr/bin',
            :user        => 'gnocchi',
            :refreshonly => 'true',
            :logoutput   => 'on_failure'
        )
       }
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts({
          :processorcount => 8,
          :concat_basedir => '/var/lib/puppet/concat'
        }))
      end

      it_configures 'gnocchi-dbsync'
    end
  end

end
