require 'spec_helper'
require 'serverspec'
require_relative '../../../../lib/serverspec/type/pacemaker_location'
require 'pry'

set :backend, :exec

xml_file = File.join File.dirname(__FILE__), '..', '..', '..', 'unit', 'puppet', 'provider', 'cib.xml'
xml_data = File.read xml_file

describe pacemaker_location('MISSING') do
  before(:each) do
    subject.cib = xml_data
  end

  it { is_expected.not_to be_present }
  its(:node) { is_expected.to be_nil }
  its(:score) { is_expected.to be_nil }
  its(:primitive) { is_expected.to be_nil }
  its(:rules) { is_expected.to be_nil }
end

describe pacemaker_location('ping_vip__public-clone-on-node-1') do
  before(:each) do
    subject.cib = xml_data
  end

  it { is_expected.to be_present }
  its(:node) { is_expected.to eq 'node-1' }
  its(:primitive) { is_expected.to eq 'ping_vip__public-clone' }
  its(:score) { is_expected.to eq '100' }
  its(:rules) { is_expected.to be_nil }
end

describe pacemaker_location('loc_ping_vip__public') do
  before(:each) do
    subject.cib = xml_data
  end

  it { is_expected.to be_present }
  its(:node) { is_expected.to be_nil }
  its(:primitive) { is_expected.to eq 'vip__public' }
  its(:score) { is_expected.to be_nil }
  its(:rules) { is_expected.to eq(
                                   [
                                       {
                                           'boolean-op' => 'or',
                                           'id' => 'loc_ping_vip__public-rule',
                                           'score' => '-INFINITY',
                                           'expressions' =>
                                               [
                                                   {
                                                       'attribute' => 'pingd',
                                                       'id' => 'loc_ping_vip__public-expression',
                                                       'operation' => 'not_defined'
                                                   },
                                                   {
                                                       'attribute' => 'pingd',
                                                       'id' => 'loc_ping_vip__public-expression-0',
                                                       'operation' => 'lte',
                                                       'value' => '0'
                                                   }
                                               ]
                                       }
                                   ]
                               ) }
end
