require 'spec_helper_acceptance'
require_relative '../../lib/serverspec/type/pacemaker_property'

describe 'pacemaker_property' do
  context 'create' do
    include_examples 'manifest', example_manifest('pacemaker_property/create.pp')

    describe pacemaker_property('cluster-delay') do
      it { is_expected.to be_present }
      its(:value) { is_expected.to eq '50' }
    end

    describe pacemaker_property('batch-limit') do
      it { is_expected.to be_present }
      its(:value) { is_expected.to eq '50' }
    end
  end

  context 'update' do
    include_examples 'manifest', example_manifest('pacemaker_property/update.pp')

    describe pacemaker_property('cluster-delay') do
      it { is_expected.to be_present }
      its(:value) { is_expected.to eq '51' }
    end

    describe pacemaker_property('batch-limit') do
      it { is_expected.to be_present }
      its(:value) { is_expected.to eq '51' }
    end
  end

  context 'delete' do
    include_examples 'manifest', example_manifest('pacemaker_property/delete.pp')

    describe pacemaker_property('cluster-delay') do
      it { is_expected.not_to be_present }
    end

    describe pacemaker_property('batch-limit') do
      it { is_expected.not_to be_present }
    end
  end
end
