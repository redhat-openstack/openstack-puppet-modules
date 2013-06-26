require 'spec_helper'

describe "datacat" do
  context "specifying template by path" do
    let(:title) { 'test' }
    let(:params) { { :template => "demo1/sheeps.erb" } }
    it { should contain_datacat_collector('test') }
    it { should contain_datacat_collector('test').with_template('demo1/sheeps.erb') }
    it { should contain_datacat_collector('test').with_template_body(/baah/) }
  end

  context "specifying template by body" do
    let(:title) { 'test' }
    let(:params) { { :template_body => "# Baah!" } }
    it { should contain_datacat_collector('test') }
    it { should contain_datacat_collector('test').with_template('inline') }
    it { should contain_datacat_collector('test').with_template_body(/Baah/) }
  end
end
