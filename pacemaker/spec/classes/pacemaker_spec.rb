require 'spec_helper'

describe 'pacemaker' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      it { is_expected.to compile }
      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('pacemaker::install') }
      it { is_expected.to contain_class('pacemaker::service') }

      case facts[:operatingsystemrelease]
      when /6\./
        it_behaves_like 'basic_setup',
                        ["pacemaker","pcs","fence-agents","cman"],
                        false
      when /7\./
        it_behaves_like 'basic_setup',
                        ["pacemaker","pcs","fence-agents-all","pacemaker-libs"],
                        true

      end
    end
  end
end
