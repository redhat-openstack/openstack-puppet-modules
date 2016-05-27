require 'spec_helper'
require 'serverspec'
require_relative '../../../../lib/serverspec/type/pacemaker_property'
require 'pry'

set :backend, :exec

xml_file = File.join File.dirname(__FILE__), '..', '..', '..', 'unit', 'puppet', 'provider', 'cib.xml'
xml_data = File.read xml_file

describe pacemaker_property('MISSING') do
  before(:each) do
    subject.cib = xml_data
  end

  it { is_expected.not_to be_present }
  its(:value) { is_expected.to be_nil }

end

describe pacemaker_property('no-quorum-policy') do
  before(:each) do
    subject.cib = xml_data
  end

  its(:value) { is_expected.to eq 'ignore' }
end

describe pacemaker_property('stonith-enabled') do
  before(:each) do
    subject.cib = xml_data
  end

  its(:value) { is_expected.to eq 'false' }
end
