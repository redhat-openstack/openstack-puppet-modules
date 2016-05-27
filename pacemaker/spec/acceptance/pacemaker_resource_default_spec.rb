require 'spec_helper_acceptance'
require_relative '../../lib/serverspec/type/pacemaker_resource_default'

describe 'pacemaker_resource_default' do
  context 'create' do
    include_examples 'manifest', example_manifest('pacemaker_resource_default/create.pp')

    describe pacemaker_resource_default('resource-stickiness') do
      it { is_expected.to be_present }
      its(:value) { is_expected.to eq '100' }
    end
  end

  context 'update' do
    include_examples 'manifest', example_manifest('pacemaker_resource_default/update.pp')

    describe pacemaker_resource_default('resource-stickiness') do
      it { is_expected.to be_present }
      its(:value) { is_expected.to eq '101' }
    end
  end

  context 'delete' do
    include_examples 'manifest', example_manifest('pacemaker_resource_default/delete.pp')

    describe pacemaker_resource_default('resource-stickiness') do
      it { is_expected.not_to be_present }
    end
  end
end
