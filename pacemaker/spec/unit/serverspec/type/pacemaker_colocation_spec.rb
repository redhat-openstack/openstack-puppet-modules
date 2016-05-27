require 'spec_helper'
require 'serverspec'
require_relative '../../../../lib/serverspec/type/pacemaker_colocation'
require 'pry'

set :backend, :exec

xml_file = File.join File.dirname(__FILE__), '..', '..', '..', 'unit', 'puppet', 'provider', 'cib.xml'
xml_data = File.read xml_file

describe pacemaker_colocation('MISSING') do
  before(:each) do
    subject.cib = xml_data
  end

  it { is_expected.not_to be_present }
  its(:first) { is_expected.to be_nil }
  its(:second) { is_expected.to be_nil }
  its(:score) { is_expected.to be_nil }
end

describe pacemaker_colocation('vip_public-with-haproxy') do
  before(:each) do
    subject.cib = xml_data
  end

  it { is_expected.to be_present }
  its(:first) { is_expected.to eq 'p_haproxy-clone' }
  its(:second) { is_expected.to eq 'vip__public' }
  its(:score) { is_expected.to eq 'INFINITY' }
end
