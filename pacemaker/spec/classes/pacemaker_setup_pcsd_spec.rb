require 'spec_helper'

describe 'pacemaker::new::setup::pcsd', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      if facts[:osfamily] == 'Debian'
        cluster_user = 'root'
        cluster_group = 'root'
      elsif facts[:osfamily] == 'RedHat'
        cluster_user = 'hacluster'
        cluster_group = 'haclient'
      else
        cluster_user = nil
        cluster_group = nil
      end

      context 'with default parameters' do
        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('pacemaker::new::setup::pcsd') }

        it { is_expected.to contain_class('pacemaker::new::params') }

        it { is_expected.to contain_pacemaker_online('setup') }

        it { is_expected.to contain_user('hacluster').with_name(cluster_user).with_groups(cluster_group) }

        pacemaker_pcsd_auth_parameters = {
            :success  => true,
            :nodes    => ['localhost'],
            :username => cluster_user,
            :password => 'CHANGEME',
            :whole    => true,
            :local    => false,
            :force    => false,
        }

        it { is_expected.to contain_pacemaker_pcsd_auth('setup').with(pacemaker_pcsd_auth_parameters) }

        create_cluster_command = '/usr/sbin/pcs cluster setup --name clustername localhost '

        it { is_expected.to contain_exec('create-cluster').with_command create_cluster_command }

        it { is_expected.to contain_exec('start-cluster') }

      end

      context 'with custom parameters' do
        let(:params) do
          {
              :cluster_nodes => {
                  'node1' => {
                      'vote' => '2',
                      'ring0' => '192.168.0.1',
                      'ring1' => '172.16.0.1',
                  },
                  'node2' => {
                      'ring0' => '192.168.0.2',
                      'ring1' => '172.16.0.2',
                  },
                  'node3' => {
                      'ring0' => '192.168.0.3',
                      'ring1' => '172.16.0.3',
                  },
              },
              :cluster_options => {
                  'token' => '1500ms',
                  'consensus' => '1500ms',
                  'ipv6' => true,
              },
              :cluster_name => 'my_cluster',
              :cluster_user => 'cluster',
              :cluster_password => 'my_pass',
          }
        end

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('pacemaker::new::setup::pcsd') }

        it { is_expected.to contain_class('pacemaker::new::params') }

        it { is_expected.to contain_pacemaker_online('setup') }

        it { is_expected.to contain_user('hacluster').with_name('cluster') }

        pacemaker_pcsd_auth_parameters = {
            :success  => true,
            :nodes    => %w(192.168.0.1 172.16.0.1 192.168.0.2 172.16.0.2 192.168.0.3 172.16.0.3),
            :username => 'cluster',
            :password => 'my_pass',
            :whole    => true,
            :local    => false,
            :force    => false,
        }

        it { is_expected.to contain_pacemaker_pcsd_auth('setup').with(pacemaker_pcsd_auth_parameters) }

        create_cluster_command = '/usr/sbin/pcs cluster setup --name my_cluster 192.168.0.1,172.16.0.1 192.168.0.2,172.16.0.2 192.168.0.3,172.16.0.3 --token 1500ms --consensus 1500ms --ipv6'

        it { is_expected.to contain_exec('create-cluster').with_command create_cluster_command }

        it { is_expected.to contain_exec('start-cluster') }

      end

    end
  end
end