require 'spec_helper'

describe 'pacemaker::new', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with default parameters' do
        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('pacemaker::new::params') }

        it { is_expected.to contain_class('pacemaker::new') }

        it { is_expected.to contain_class('pacemaker::new::firewall') }

        it { is_expected.to contain_class('pacemaker::new::install') }

        it { is_expected.to contain_class('pacemaker::new::setup') }

        it { is_expected.to contain_class('pacemaker::new::service') }
      end

    end
  end
end
