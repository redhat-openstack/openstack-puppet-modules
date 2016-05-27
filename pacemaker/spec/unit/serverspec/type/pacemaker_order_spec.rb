require 'spec_helper'
require 'serverspec'
require_relative '../../../../lib/serverspec/type/pacemaker_order'
require 'pry'

set :backend, :exec

xml_file = File.join File.dirname(__FILE__), '..', '..', '..', 'unit', 'puppet', 'provider', 'cib.xml'
xml_data = File.read xml_file

describe pacemaker_order('MISSING') do
  before(:each) do
    subject.cib = xml_data
  end

  it { is_expected.not_to be_present }
  its(:first) { is_expected.to be_nil }
  its(:second) { is_expected.to be_nil }
  its(:then) { is_expected.to be_nil }
  its(:score) { is_expected.to be_nil }
end

describe pacemaker_order('p_neutron-dhcp-agent-after-p_neutron-plugin-openvswitch-agent-clone') do
  before(:each) do
    subject.cib = xml_data
  end

  it { is_expected.to be_present }
  its(:first) { is_expected.to eq 'p_neutron-plugin-openvswitch-agent-clone' }
  its(:second) { is_expected.to eq 'p_neutron-dhcp-agent' }
  its(:then) { is_expected.to eq 'p_neutron-dhcp-agent' }
  its(:score) { is_expected.to eq 'INFINITY' }
  its(:first_action) { is_expected.to be_nil }
  its(:second_action) { is_expected.to be_nil }
  its(:then_action) { is_expected.to be_nil }
  its(:kind) { is_expected.to be_nil }
  its(:symmetrical) { is_expected.to be_nil }
  its(:require_all) { is_expected.to be_nil }
end

describe pacemaker_order('order-test1-test2-Mandatory') do
  before(:each) do
    subject.cib = xml_data
  end

  it { is_expected.to be_present }
  its(:first) { is_expected.to eq 'test1' }
  its(:second) { is_expected.to eq 'test2' }
  its(:then) { is_expected.to eq 'test2' }
  its(:score) { is_expected.to be_nil }
  its(:first_action) { is_expected.to eq 'promote' }
  its(:second_action) { is_expected.to eq 'start' }
  its(:then_action) { is_expected.to eq 'start' }
  its(:kind) { is_expected.to eq 'mandatory' }
  its(:symmetrical) { is_expected.to eq 'true' }
  its(:require_all) { is_expected.to eq 'true' }
end

