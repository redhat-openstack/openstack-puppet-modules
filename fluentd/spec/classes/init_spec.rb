require 'spec_helper'

RSpec.describe 'fluentd' do
  shared_examples 'works' do
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_class('fluentd') }
    it { is_expected.to contain_class('fluentd::install') }
    it { is_expected.to contain_class('fluentd::service') }
  end

  context 'when osfamily is debian' do
    let(:facts) do
      { osfamily: 'Debian', lsbdistid: 'Ubuntu', lsbdistcodename: 'trusty' }
    end

    include_examples 'works'
  end

  context 'with defaults for all parameters' do
    let(:facts) { { osfamily: 'RedHat' } }

    include_examples 'works'
  end
end
