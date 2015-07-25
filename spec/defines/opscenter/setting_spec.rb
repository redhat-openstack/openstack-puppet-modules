require 'spec_helper'
describe 'cassandra::opscenter::setting' do
  let(:pre_condition) { [
    'define ini_setting($ensure = nil,
       $path                    = nil,
       $section                 = nil,
       $key_val_separator       = nil,
       $setting                 = nil,
       $value                   = nil) {}'
  ] }

  context 'Test that settings can be set.' do
    let(:title) { 'section setting' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'section',
        :setting => 'setting',
        :value   => 'value',
      }
    end

    it {
      should contain_ini_setting('section setting').with({
        'value' => 'value',
      })
    }
  end

  context 'Test that settings can be removed.' do
    let(:title) { 'section setting' }
    let :params do
      {
        :path    => '/path/to/file',
        :section => 'not',
        :setting => 'wanted',
      }
    end

    it {
      should contain_ini_setting('not wanted').with({
        'ensure' => 'absent',
      })
    }
  end
end
