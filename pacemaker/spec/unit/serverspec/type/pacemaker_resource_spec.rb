require 'spec_helper'
require 'serverspec'
require_relative '../../../../lib/serverspec/type/pacemaker_resource'
require 'pry'

set :backend, :exec

xml_file = File.join File.dirname(__FILE__), '..', '..', '..', 'unit', 'puppet', 'provider', 'cib.xml'
xml_data = File.read xml_file

describe pacemaker_resource('MISSING') do
  before(:each) do
    subject.cib = xml_data
  end

  # basic definition
  it { is_expected.not_to be_present }
  its(:full_name) { is_expected.to be_nil }
  its(:res_class) { is_expected.to be_nil }
  its(:res_provider) { is_expected.to be_nil }
  its(:res_type) { is_expected.to be_nil }

  # attributes
  its(:parameters) { is_expected.to be_nil }
  its(:metadata) { is_expected.to be_nil }
  its(:operations) { is_expected.to be_nil }

  # complex
  it { is_expected.not_to be_complex }
  its(:complex_type) { is_expected.to be_nil }
  it { is_expected.not_to be_simple }
  it { is_expected.not_to be_clone }
  it { is_expected.not_to be_master }
  it { is_expected.not_to be_group }
  its(:group_name) { is_expected.to be_nil }
  its(:complex_metadata) { is_expected.to be_nil }

  # target-state
  it { is_expected.not_to be_started }
  it { is_expected.not_to be_managed }

  # actual status
  it { is_expected.not_to be_running }
  it { is_expected.not_to be_failed }
  its(:status) { is_expected.to be_nil }
  it 'has service location on node-1' do
    expect(subject.has_location_on? 'node-1').to be_nil
  end
end

describe pacemaker_resource('p_haproxy') do
  before(:each) do
    subject.cib = xml_data
  end

  # basic definition
  it { is_expected.to be_present }
  its(:full_name) { is_expected.to eq 'p_haproxy-clone' }
  its(:res_class) { is_expected.to eq 'ocf' }
  its(:res_provider) { is_expected.to eq 'mirantis' }
  its(:res_type) { is_expected.to eq 'ns_haproxy' }

  it { is_expected.to be_started }
  it { is_expected.to be_managed }

  # attributes
  its(:parameters) { is_expected.to eq(
                                        {
                                            'ns' => 'haproxy'
                                        }
                                    )
  }
  its(:metadata) { is_expected.to eq(
                                      {
                                          'migration-threshold' => '3',
                                          'failure-timeout' => '120',
                                      }
                                  )
  }
  its(:operations) { is_expected.to eq(
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
                                            }
                                        ]
                                    )
  }

  # complex
  it { is_expected.to be_complex }
  its(:complex_type) { is_expected.to eq 'clone' }
  it { is_expected.not_to be_simple }
  it { is_expected.to be_clone }
  it { is_expected.not_to be_master }
  it { is_expected.not_to be_group }
  its(:group_name) { is_expected.to be_nil }
  its(:complex_metadata) { is_expected.to eq (
                                                 {
                                                     'interleave' => 'true'
                                                 }
                                             )
  }

  # target-state
  it { is_expected.to be_started }
  it { is_expected.to be_managed }

  # actual status
  it { is_expected.to be_running }
  it { is_expected.not_to be_failed }
  its(:status) { is_expected.to eq 'start' }

  it 'should be started on node-1' do
    expect(subject.status 'node-1').to eq 'start'
  end
  it 'should be stopped on node-3' do
    expect(subject.status 'node-3').to eq 'stop'
  end
  it 'has service location on node-1' do
    expect(subject.has_location_on? 'node-1').to eq true
  end

end

describe pacemaker_resource('test1') do
  before(:each) do
    subject.cib = xml_data
  end

  # basic definition
  it { is_expected.to be_present }
  its(:full_name) { is_expected.to eq 'test1' }

  it { is_expected.to be_started }
  it { is_expected.to be_managed }

  # complex
  it { is_expected.not_to be_complex }
  its(:complex_type) { is_expected.to eq nil }
  it { is_expected.to be_simple }
  it { is_expected.not_to be_clone }
  it { is_expected.not_to be_master }
  it { is_expected.to be_group }
  its(:group_name) { is_expected.to eq 'test' }

  # actual status
  it { is_expected.not_to be_running }
  it { is_expected.not_to be_failed }
  its(:status) { is_expected.to be_nil }
  it 'has service location on node-1' do
    expect(subject.has_location_on? 'node-1').to eq false
  end
end

describe pacemaker_resource('p_ceilometer-agent-central') do
  before(:each) do
    subject.cib = xml_data
  end

  # basic definition
  it { is_expected.to be_present }
  its(:full_name) { is_expected.to eq 'p_ceilometer-agent-central' }

  it { is_expected.not_to be_started }
  it { is_expected.not_to be_managed }
end
