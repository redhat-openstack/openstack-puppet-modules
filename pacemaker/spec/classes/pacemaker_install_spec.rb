require 'spec_helper'

describe 'pacemaker::new::install', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      package_list = begin
        if facts[:osfamily] == 'RedHat'
          if facts[:operatingsystemmajrelease].to_i >= 7
            %w(pacemaker pcs fence-agents-all pacemaker-libs)
          else
            %w(pacemaker pcs fence-agents cman)
          end
        elsif facts[:osfamily] == 'Debian'
          if facts[:operatingsystem] == 'Ubuntu' && facts[:operatingsystemmajrelease].to_i >= 16
            %w(pacemaker corosync pacemaker-cli-utils resource-agents)
          else
            %w(pacemaker-mgmt pacemaker corosync pacemaker-cli-utils resource-agents)
          end
        else
          []
        end
      end

      context 'with default parameters' do
        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('pacemaker::new::install') }

        it { is_expected.to contain_class('pacemaker::new::params') }

        package_list.each do |package|
          it { is_expected.to contain_package(package) }
        end

        it { is_expected.to contain_file('pacemaker-config-dir').with_ensure('directory').with_path('/etc/pacemaker') }

        it { is_expected.to contain_file('corosync-config-dir').with_ensure('directory').with_path('/etc/corosync') }
      end

      context 'with custom parameters' do
        let(:params) do
          {
              package_manage: true,
              package_list: %w(pkg1 pkg2),
              package_provider: 'gem',
              package_ensure: 'latest',
          }
        end

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('pacemaker::new::install') }

        it { is_expected.to contain_class('pacemaker::new::params') }

        parameters = {
            ensure: 'latest',
            provider: 'gem',
        }

        it { is_expected.to contain_package('pkg1').with(parameters) }

        it { is_expected.to contain_package('pkg2').with(parameters) }

        it { is_expected.to contain_file('pacemaker-config-dir').with_ensure('directory').with_path('/etc/pacemaker') }

        it { is_expected.to contain_file('corosync-config-dir').with_ensure('directory').with_path('/etc/corosync') }
      end

      context 'with manage disabled' do
        let(:params) do
          {
            package_manage: false
          }
        end

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('pacemaker::new::install') }

        it { is_expected.to contain_class('pacemaker::new::params') }

        package_list.each do |package|
          it { is_expected.not_to contain_package(package) }
        end

        it { is_expected.to contain_file('pacemaker-config-dir').with_ensure('directory').with_path('/etc/pacemaker') }

        it { is_expected.to contain_file('corosync-config-dir').with_ensure('directory').with_path('/etc/corosync') }
      end

    end
  end
end
