require 'spec_helper'

describe 'pacemaker::contain', type: :define do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:pre_condition) do
        <<-eof
class my_dummy_class {}
        eof
      end


      context 'with default parameters' do
        let(:title) { 'my_dummy_class' }
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to include_class('my_dummy_class') }
        it { is_expected.to contain_class('my_dummy_class') }
      end
      context 'with class_name parameters' do
        let(:title) { 'something_else' }
        let(:params) { { 'class_name' => 'my_dummy_class' }}
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to include_class('my_dummy_class') }
        it { is_expected.to contain_class('my_dummy_class') }
      end
      context 'fail with an absolute class name' do
        let(:title) { '::dummy_class' }
        it { is_expected.not_to compile }
      end
    end
  end
end
