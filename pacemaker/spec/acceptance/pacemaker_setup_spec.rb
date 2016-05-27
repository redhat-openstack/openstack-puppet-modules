require 'spec_helper_acceptance'

context 'pacemaker setup' do
  describe service('corosync') do
    it { is_expected.to be_running }
    it { is_expected.to be_enabled }
  end

  describe service('pacemaker') do
    it { is_expected.to be_running }
    it { is_expected.to be_enabled }
  end
end
