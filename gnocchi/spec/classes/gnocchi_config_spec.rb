require 'spec_helper'

describe 'gnocchi::config' do

  let :params do
    { :gnocchi_config => {
        'DEFAULT/foo' => { 'value'  => 'fooValue' },
        'DEFAULT/bar' => { 'value'  => 'barValue' },
        'DEFAULT/baz' => { 'ensure' => 'absent' }
      }
    }
  end

  it 'configures arbitrary gnocchi configurations' do
    is_expected.to contain_gnocchi_config('DEFAULT/foo').with_value('fooValue')
    is_expected.to contain_gnocchi_config('DEFAULT/bar').with_value('barValue')
    is_expected.to contain_gnocchi_config('DEFAULT/baz').with_ensure('absent')
  end

end
