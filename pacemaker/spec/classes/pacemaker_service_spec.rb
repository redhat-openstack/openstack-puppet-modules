require 'spec_helper'

describe 'pacemaker::new::service', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with default parameters' do
        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('pacemaker::new::params') }

        it { is_expected.to contain_class('pacemaker::new::service') }

        it { is_expected.to contain_service('corosync') }

        it { is_expected.to contain_service('pacemaker') }

        it { is_expected.to contain_service('pcsd') }
      end

      context 'with service manage disabled' do
        let(:params) do
          {
              :corosync_manage => false,
              :pacemaker_manage => false,
              :pcsd_manage => false,
          }
        end

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('pacemaker::new::params') }

        it { is_expected.to contain_class('pacemaker::new::service') }

        it { is_expected.not_to contain_service('corosync') }

        it { is_expected.not_to contain_service('pacemaker') }

        it { is_expected.not_to contain_service('pcsd') }
      end

    end
  end
end
