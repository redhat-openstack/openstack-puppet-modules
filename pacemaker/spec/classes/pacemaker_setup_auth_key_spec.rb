require 'spec_helper'

describe 'pacemaker::new::setup::auth_key', type: :class do
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

        it { is_expected.to contain_class('pacemaker::new::params') }

        it { is_expected.to contain_class('pacemaker::new::setup::auth_key') }

        corosync_key_parameters = {
            :ensure => 'absent',
            :path => '/etc/corosync/authkey',
            :content => nil,
            :owner => cluster_user,
            :group => cluster_group,
            :mode => '0640',
        }

        it { is_expected.to contain_file('corosync-auth-key').with(corosync_key_parameters) }

        pacemaker_key_parameters = {
            :ensure => 'absent',
            :path => '/etc/pacemaker/authkey',
            :target => '/etc/corosync/authkey',
            :owner => cluster_user,
            :group => cluster_group,
            :mode => '0640',
        }

        it { is_expected.to contain_file('pacemaker-auth-key').with(pacemaker_key_parameters) }
      end

      context 'with custom parameters' do
        let(:params) do
          {
              :cluster_auth_enabled => true,
              :cluster_auth_key => '12345',
              :cluster_user => 'my_user',
              :cluster_group => 'my_group',
          }
        end

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('pacemaker::new::params') }

        it { is_expected.to contain_class('pacemaker::new::setup::auth_key') }

        corosync_key_parameters = {
            :ensure => 'present',
            :path => '/etc/corosync/authkey',
            :content => '12345',
            :owner => 'my_user',
            :group => 'my_group',
            :mode => '0640',
        }

        it { is_expected.to contain_file('corosync-auth-key').with(corosync_key_parameters) }

        pacemaker_key_parameters = {
            :ensure => 'present',
            :path => '/etc/pacemaker/authkey',
            :target => '/etc/corosync/authkey',
            :owner => 'my_user',
            :group => 'my_group',
            :mode => '0640',
        }

        it { is_expected.to contain_file('pacemaker-auth-key').with(pacemaker_key_parameters) }
      end

    end
  end
end