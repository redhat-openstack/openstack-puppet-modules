require 'spec_helper_acceptance'
require_relative '../../lib/serverspec/type/pacemaker_colocation'
require_relative '../../lib/serverspec/type/pacemaker_resource'

describe 'pacemaker_colocation' do
  context 'create' do
    include_examples 'manifest', example_manifest('pacemaker_colocation/create.pp')

    describe pacemaker_colocation('colocation-test2_with_and_after_colocation-test1') do
      it { is_expected.to be_present }
      its(:first) { is_expected.to eq 'colocation-test1' }
      its(:second) { is_expected.to eq 'colocation-test2' }
      its(:score) { is_expected.to eq '200' }
    end

    describe pacemaker_colocation('colocation-test3_with_and_after_colocation-test1') do
      it { is_expected.to be_present }
      its(:first) { is_expected.to eq 'colocation-test1' }
      its(:second) { is_expected.to eq 'colocation-test3' }
      its(:score) { is_expected.to eq '400' }
    end

    describe pacemaker_resource('colocation-test1') do
      it { is_expected.to be_present }
    end

    describe pacemaker_resource('colocation-test2') do
      it { is_expected.to be_present }
    end

    describe pacemaker_resource('colocation-test3') do
      it { is_expected.to be_present }
    end
  end

  context 'update' do
    include_examples 'manifest', example_manifest('pacemaker_colocation/update.pp')

    describe pacemaker_colocation('colocation-test2_with_and_after_colocation-test1') do
      it { is_expected.to be_present }
      its(:first) { is_expected.to eq 'colocation-test1' }
      its(:second) { is_expected.to eq 'colocation-test2' }
      its(:score) { is_expected.to eq '201' }
    end

    describe pacemaker_colocation('colocation-test3_with_and_after_colocation-test1') do
      it { is_expected.to be_present }
      its(:first) { is_expected.to eq 'colocation-test1' }
      its(:second) { is_expected.to eq 'colocation-test3' }
      its(:score) { is_expected.to eq '401' }
    end

    describe pacemaker_resource('colocation-test1') do
      it { is_expected.to be_present }
    end

    describe pacemaker_resource('colocation-test2') do
      it { is_expected.to be_present }
    end

    describe pacemaker_resource('colocation-test3') do
      it { is_expected.to be_present }
    end
  end

  context 'delete' do
    include_examples 'manifest', example_manifest('pacemaker_colocation/delete.pp')

    describe pacemaker_colocation('colocation-test2_with_and_after_colocation-test1') do
      it { is_expected.not_to be_present }
    end

    describe pacemaker_colocation('colocation-test3_with_and_after_colocation-test1') do
      it { is_expected.not_to be_present }
    end

    describe pacemaker_resource('colocation-test1') do
      it { is_expected.not_to be_present }
    end

    describe pacemaker_resource('colocation-test2') do
      it { is_expected.not_to be_present }
    end

    describe pacemaker_resource('colocation-test3') do
      it { is_expected.not_to be_present }
    end
  end
end
