require 'spec_helper_acceptance'
require_relative '../../lib/serverspec/type/pacemaker_resource'

describe 'pacemaker_resource' do
  context 'create' do
    include_examples 'manifest', example_manifest('pacemaker_resource/create.pp')

    describe pacemaker_resource 'test-simple1' do
      it { is_expected.to be_present }
      its(:res_class) { is_expected.to eq('ocf') }
      its(:res_provider) { is_expected.to eq('pacemaker') }
      its(:res_type) { is_expected.to eq('Dummy') }
      its(:parameters) { is_expected.to eq(
                                            'fake' => '1'
                                        )
      }
    end

    describe pacemaker_resource 'test-simple2' do
      it { is_expected.to be_present }
      its(:res_class) { is_expected.to eq('ocf') }
      its(:res_provider) { is_expected.to eq('pacemaker') }
      its(:res_type) { is_expected.to eq('Dummy') }
      its(:parameters) { is_expected.to eq(
                                            'fake' => '2'
                                        )
      }
    end

    describe pacemaker_resource 'test-simple-params1' do
      it { is_expected.to be_present }

      its(:res_class) { is_expected.to eq('ocf') }

      its(:res_provider) { is_expected.to eq('pacemaker') }

      its(:res_type) { is_expected.to eq('Dummy') }

      its(:parameters) { are_expected.to eq(
                                             'fake' => '3'
                                         )
      }

      its(:metadata) { is_expected.to eq(
                                          'migration-threshold' => '3',
                                          'failure-timeout' => '120'
                                      )
      }
      its(:operations) { are_expected.to eq(
                                             [
                                                 {
                                                     'interval' => '20',
                                                     'name' => 'monitor',
                                                     'timeout' => '10',
                                                 },
                                                 {
                                                     'interval' => '0',
                                                     'name' => 'start',
                                                     'timeout' => '30',
                                                 },
                                                 {
                                                     'interval' => '0',
                                                     'name' => 'stop',
                                                     'timeout' => '30',
                                                 },
                                             ]
                                         )
      }
    end

    describe pacemaker_resource 'test-simple-params2' do
      it { is_expected.to be_present }

      its(:res_class) { is_expected.to eq('ocf') }

      its(:res_provider) { is_expected.to eq('pacemaker') }

      its(:res_type) { is_expected.to eq('Dummy') }

      its(:parameters) { are_expected.to eq('fake' => '4') }

      its(:metadata) { is_expected.to eq(
                                          'migration-threshold' => '3',
                                          'failure-timeout' => '120'
                                      )
      }
      its(:operations) { are_expected.to eq(
                                             [
                                                 {
                                                     'interval' => '10',
                                                     'name' => 'monitor',
                                                     'timeout' => '10',
                                                 },
                                                 {
                                                     'interval' => '60',
                                                     'name' => 'monitor',
                                                     'timeout' => '10',
                                                 },
                                                 {
                                                     'interval' => '0',
                                                     'name' => 'start',
                                                     'timeout' => '30',
                                                 },
                                                 {
                                                     'interval' => '0',
                                                     'name' => 'stop',
                                                     'timeout' => '30',
                                                 }
                                             ]
                                         )
      }
    end

    describe pacemaker_resource 'test-clone' do
      it { is_expected.to be_present }
      its(:complex_type) { is_expected.to eq 'clone' }
      its(:complex_metadata) { is_expected.to eq(
                                                  'interleave' => 'true'
                                              )
      }
      its(:parameters) { are_expected.to eq(
                                             'fake' => '5'
                                         )
      }
    end

    describe pacemaker_resource 'test-master' do
      it { is_expected.to be_present }
      its(:complex_type) { is_expected.to eq 'master' }
      its(:res_type) { is_expected.to eq 'Stateful' }
      its(:parameters) { are_expected.to eq(
                                             'fake' => '6'
                                         )
      }
      its(:complex_metadata) { is_expected.to eq(
                                                  'interleave' => 'true',
                                                  'master-max' => '1'
                                              )
      }
    end

    describe pacemaker_resource 'test-clone-change' do
      it { is_expected.to be_present }
      its(:complex_type) { is_expected.to be_nil }
      its(:parameters) { are_expected.to eq(
                                             'fake' => '7'
                                         )
      }
    end

    describe pacemaker_resource 'test-master-change' do
      it { is_expected.to be_present }
      its(:complex_type) { is_expected.to eq 'master' }
      its(:res_type) { is_expected.to eq 'Stateful' }
      its(:parameters) { are_expected.to eq(
                                             'fake' => '8'
                                         )
      }
    end
  end

  context 'update' do
    include_examples 'manifest', example_manifest('pacemaker_resource/update.pp')

    describe pacemaker_resource 'test-simple1' do
      it { is_expected.to be_present }
    end

    describe pacemaker_resource 'test-simple2' do
      it { is_expected.to be_present }
    end

    describe pacemaker_resource 'test-simple-params1' do
      it { is_expected.to be_present }
    end

    describe pacemaker_resource 'test-simple-params2' do
      it { is_expected.to be_present }
    end

    describe pacemaker_resource 'test-clone' do
      it { is_expected.to be_present }
      its(:complex_type) { is_expected.to eq 'clone' }
    end

    describe pacemaker_resource 'test-master' do
      it { is_expected.to be_present }
      its(:complex_type) { is_expected.to eq 'master' }
    end

    describe pacemaker_resource 'test-clone-change' do
      it { is_expected.to be_present }
      its(:complex_type) { is_expected.to eq 'clone' }
      its(:parameters) { are_expected.to eq(
                                             'fake' => '8'
                                         )
      }
    end

    describe pacemaker_resource 'test-master-change' do
      it { is_expected.to be_present }
      its(:complex_type) { is_expected.to be_nil }
      its(:parameters) { are_expected.to eq(
                                             'fake' => '9'
                                         )
      }
    end
  end

  context 'delete' do
    include_examples 'manifest', example_manifest('pacemaker_resource/delete.pp')

    describe pacemaker_resource 'test-simple1' do
      it { is_expected.not_to be_present }
    end

    describe pacemaker_resource 'test-simple2' do
      it { is_expected.not_to be_present }
    end

    describe pacemaker_resource 'test-simple-params1' do
      it { is_expected.not_to be_present }
    end

    describe pacemaker_resource 'test-simple-params2' do
      it { is_expected.not_to be_present }
    end

    describe pacemaker_resource 'test-clone' do
      it { is_expected.not_to be_present }
    end

    describe pacemaker_resource 'test-master' do
      it { is_expected.not_to be_present }
    end

    describe pacemaker_resource 'test-clone-change' do
      it { is_expected.not_to be_present }
    end

    describe pacemaker_resource 'test-master-change' do
      it { is_expected.not_to be_present }
    end
  end
end
