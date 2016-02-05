require 'spec_helper'

RSpec.describe 'fluentd::service' do
  context 'on RedHat based system' do
    let(:facts) { { osfamily: 'RedHat' } }

    it { is_expected.to contain_service('td-agent').with(provider: 'redhat') }
  end

  context 'on Debian based system' do
    let(:facts) do
      { osfamily: 'Debian', lsbdistid: 'Ubuntu', lsbdistcodename: 'trusty' }
    end

    it { is_expected.to contain_service('td-agent').without(:provider) }
  end
end
