require 'spec_helper_acceptance'
require_relative '../../lib/serverspec/type/pacemaker_location'
require_relative '../../lib/serverspec/type/pacemaker_resource'

describe 'pacemaker_location' do
  context 'create' do
    include_examples 'manifest', example_manifest('pacemaker_location/create.pp')

    describe pacemaker_location('location-test1_location_with_rule') do
      it { is_expected.to be_present }
      its(:primitive) { is_expected.to eq 'location-test1' }
      its(:rules) { are_expected.to eq(
                                        [
                                            {
                                                'boolean-op' => 'or',
                                                'id' => 'location-test1_location_with_rule-rule-0',
                                                'score' => '100',
                                                'expressions' => [
                                                    {
                                                        'attribute' => 'a',
                                                        'id' => 'location-test1_location_with_rule-rule-0-expression-0',
                                                        'operation' => 'defined',
                                                    }
                                                ]
                                            },
                                            {
                                                'boolean-op' => 'or',
                                                'id' => 'location-test1_location_with_rule-rule-1',
                                                'score' => '200',
                                                'expressions' => [
                                                    {
                                                        'attribute' => 'b',
                                                        'id' => 'location-test1_location_with_rule-rule-1-expression-0',
                                                        'operation' => 'defined',
                                                    }
                                                ]
                                            }
                                        ]
                                    )
      }
    end

    describe pacemaker_location('location-test1_location_with_score') do
      it { is_expected.to be_present }
      its(:primitive) { is_expected.to eq 'location-test1' }
      its(:score) { is_expected.to eq '200' }
      its(:node) { is_expected.to eq 'node' }
    end

    describe pacemaker_resource('location-test1') do
      it { is_expected.to be_present }
    end
  end

  context 'update' do
    include_examples 'manifest', example_manifest('pacemaker_location/update.pp')

    describe pacemaker_location('location-test1_location_with_rule') do
      it { is_expected.to be_present }
      its(:primitive) { is_expected.to eq 'location-test1' }
      its(:rules) { are_expected.to eq(
                                        [
                                            {
                                                'boolean-op' => 'or',
                                                'id' => 'location-test1_location_with_rule-rule-0',
                                                'score' => '101',
                                                'expressions' => [
                                                    {
                                                        'attribute' => 'a',
                                                        'id' => 'location-test1_location_with_rule-rule-0-expression-0',
                                                        'operation' => 'defined',
                                                    }
                                                ]
                                            },
                                            {
                                                'boolean-op' => 'or',
                                                'id' => 'location-test1_location_with_rule-rule-1',
                                                'score' => '201',
                                                'expressions' => [
                                                    {
                                                        'attribute' => 'b',
                                                        'id' => 'location-test1_location_with_rule-rule-1-expression-0',
                                                        'operation' => 'defined',
                                                    }
                                                ]
                                            }
                                        ]
                                    )
      }
    end

    describe pacemaker_location('location-test1_location_with_score') do
      it { is_expected.to be_present }
      its(:primitive) { is_expected.to eq 'location-test1' }
      its(:score) { is_expected.to eq '201' }
      its(:node) { is_expected.to eq 'node' }
    end

    describe pacemaker_resource('location-test1') do
      it { is_expected.to be_present }
    end
  end

  context 'delete' do
    include_examples 'manifest', example_manifest('pacemaker_location/delete.pp')

    describe pacemaker_location('location-test1_location_with_rule') do
      it { is_expected.not_to be_present }
    end

    describe pacemaker_location('location-test1_location_with_score') do
      it { is_expected.not_to be_present }
    end

    describe pacemaker_resource('location-test1') do
      it { is_expected.not_to be_present }
    end
  end
end
