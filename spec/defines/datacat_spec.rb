require 'spec_helper'

describe "datacat" do
  context "munging template bodies" do
    let(:title) { 'demo1' }
    let(:params) { { :template => "demo1/sheeps.erb" } }
    it { should contain_datacat_collector('demo1') }
    it { should contain_datacat_collector('demo1').with_template('demo1/sheeps.erb') }
  end
end
