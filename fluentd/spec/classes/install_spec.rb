require 'spec_helper'

RSpec.describe 'fluentd::install' do
  shared_examples 'package and configs' do
    it { is_expected.to contain_package('td-agent') }
    it { is_expected.to contain_file('/etc/td-agent/td-agent.conf') }
    it { is_expected.to contain_file('/etc/td-agent/config.d') }
  end

  context 'on RedHat based system' do
    let(:facts) { { osfamily: 'RedHat' } }

    it { is_expected.to contain_yumrepo('treasuredata') }

    include_examples 'package and configs'
  end

  context 'on Debian based system' do
    let(:facts) do
      { osfamily: 'Debian', lsbdistid: 'Ubuntu', lsbdistcodename: 'trusty' }
    end

    it { is_expected.to contain_apt__source('treasuredata') }

    include_examples 'package and configs'
  end

  context 'on unsupported system' do
    let(:facts) { { osfamily: 'Darwin' } }

    it { is_expected.not_to compile }
  end
end
