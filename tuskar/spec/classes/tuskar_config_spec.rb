require 'spec_helper'

describe 'tuskar::config' do

  let :params do
    { :tuskar_config => {
        'DEFAULT/foo' => { 'value'  => 'fooValue' },
        'DEFAULT/bar' => { 'value'  => 'barValue' },
        'DEFAULT/baz' => { 'ensure' => 'absent' }
      }
    }
  end

  it 'configures arbitrary tuskar configurations' do
    is_expected.to contain_tuskar_config('DEFAULT/foo').with_value('fooValue')
    is_expected.to contain_tuskar_config('DEFAULT/bar').with_value('barValue')
    is_expected.to contain_tuskar_config('DEFAULT/baz').with_ensure('absent')
  end

end
