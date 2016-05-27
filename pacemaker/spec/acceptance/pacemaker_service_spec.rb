require 'spec_helper_acceptance'
require_relative '../../lib/serverspec/type/pacemaker_resource'

describe 'service' do
  context 'start' do
    include_examples 'manifest', example_manifest('service/start.pp')

    describe pacemaker_resource 'service-test1' do
      it { is_expected.to be_present }
      its(:res_class) { is_expected.to eq('ocf') }
      its(:res_provider) { is_expected.to eq('pacemaker') }
      its(:res_type) { is_expected.to eq('Dummy') }
      its(:parameters) { is_expected.to eq(
                                            'fake' => '1'
                                        )
      }
      its(:operations) { are_expected.to eq(
                                             [
                                                 {
                                                     'interval' => '10',
                                                     'name' => 'monitor',
                                                     'timeout' => '10',
                                                 },
                                             ]
                                         )
      }

      # status check
      it { is_expected.to be_running }

      it { expect(subject.has_location_on? 'node').to eq true }
    end

    describe pacemaker_resource 'service-test2' do
      it { is_expected.to be_present }
      its(:res_class) { is_expected.to eq('ocf') }
      its(:res_provider) { is_expected.to eq('pacemaker') }
      its(:res_type) { is_expected.to eq('Dummy') }
      its(:parameters) { is_expected.to eq(
                                            'fake' => '2'
                                        )
      }
      its(:operations) { are_expected.to eq(
                                             [
                                                 {
                                                     'interval' => '10',
                                                     'name' => 'monitor',
                                                     'timeout' => '10',
                                                 },
                                             ]
                                         )
      }

      # status check
      it { is_expected.to be_running }

      it { expect(subject.has_location_on? 'node').to eq true }
    end

  end

  context 'stop' do
    include_examples 'manifest', example_manifest('service/stop.pp')

    describe pacemaker_resource 'service-test1' do
      it { is_expected.to be_present }
      its(:res_class) { is_expected.to eq('ocf') }
      its(:res_provider) { is_expected.to eq('pacemaker') }
      its(:res_type) { is_expected.to eq('Dummy') }
      its(:parameters) { is_expected.to eq(
                                            'fake' => '1'
                                        )
      }
      its(:operations) { are_expected.to eq(
                                             [
                                                 {
                                                     'interval' => '10',
                                                     'name' => 'monitor',
                                                     'timeout' => '10',
                                                 },
                                             ]
                                         )
      }

      # status check
      it { is_expected.not_to be_running }

      it { expect(subject.has_location_on? 'node').to eq false }
    end

    describe pacemaker_resource 'service-test2' do
      it { is_expected.to be_present }
      its(:res_class) { is_expected.to eq('ocf') }
      its(:res_provider) { is_expected.to eq('pacemaker') }
      its(:res_type) { is_expected.to eq('Dummy') }
      its(:parameters) { is_expected.to eq(
                                            'fake' => '2'
                                        )
      }
      its(:operations) { are_expected.to eq(
                                             [
                                                 {
                                                     'interval' => '10',
                                                     'name' => 'monitor',
                                                     'timeout' => '10',
                                                 },
                                             ]
                                         )
      }

      # status check
      it { is_expected.not_to be_running }

      it { expect(subject.has_location_on? 'node').to eq false }
    end

  end

  context 'clean' do
    include_examples 'manifest', example_manifest('service/clean.pp')

    describe pacemaker_resource 'service-test1' do
      it { is_expected.not_to be_present }
    end

    describe pacemaker_resource 'service-test2' do
      it { is_expected.not_to be_present }
    end

  end
end
