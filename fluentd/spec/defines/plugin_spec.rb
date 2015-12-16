require 'spec_helper'

RSpec.describe 'fluentd::plugin' do
  let(:pre_condition) { 'include fluentd' }
  let(:title) { 'fluent-plugin-test' }

  context 'on RedHat based system' do
    let(:facts) { { osfamily: 'RedHat' } }

    it { is_expected.to contain_package(title).with(provider: 'tdagent') }
  end

  context 'on Debian based system' do
    let(:facts) do
      { osfamily: 'Debian', lsbdistid: 'Ubuntu', lsbdistcodename: 'trusty' }
    end

    it { is_expected.to contain_package(title).with(provider: 'tdagent') }
  end
end
