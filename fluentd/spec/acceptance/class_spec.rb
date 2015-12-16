require 'spec_helper_acceptance'

RSpec.describe 'fluentd' do
  it 'runs successfully' do
    manifest = File.read(File.expand_path('../../examples/init.pp', __dir__))

    # Run it twice and test for idempotency
    apply_manifest(manifest, catch_failures: true)
    expect(apply_manifest(manifest, catch_failures: true).exit_code).to be_zero
  end

  describe package('td-agent') do
    it { is_expected.to be_installed }
  end

  describe service('td-agent') do
    it { is_expected.to be_enabled.with_level(3) }
    it { is_expected.to be_running }
  end
end
