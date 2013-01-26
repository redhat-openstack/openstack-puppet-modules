require 'spec_helper'

describe 'demo1' do
    it { should create_notify('demo1') }
    it { should create_datacat('/tmp/demo1').with_template('sheeps') }
end
