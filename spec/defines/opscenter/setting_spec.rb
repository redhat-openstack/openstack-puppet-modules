require 'spec_helper'
describe 'cassandra::opscenter::setting' do
  let(:pre_condition) { [
    'define ini_setting($ensure,
       $path,
       $section,
       $key_val_separator,
       $setting,
       $value) {}'
  ] }

  context 'Test that settings can be set.' do
    let(:title) { 'section setting' }
    let :params do
      {
        :path         => '/path/to/file',
        :section      => 'section',
        :setting      => 'setting',
        :value        => 'value',
      }
    end

    it {
      should contain_ini_setting('section setting').with({
        'ensure'            => 'present',
        'path'              => '/path/to/file',
        'section'           => 'section',
        'setting'           => 'setting',
        'value'             => 'value',
        'key_val_separator' => ' = ',
      })
    }
  end
end
