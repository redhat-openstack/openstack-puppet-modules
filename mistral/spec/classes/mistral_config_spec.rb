require 'spec_helper'

describe 'mistral::config' do

  let :params do
    { :mistral_config => {
        'DEFAULT/foo' => { 'value'  => 'fooValue' },
        'DEFAULT/bar' => { 'value'  => 'barValue' },
        'DEFAULT/baz' => { 'ensure' => 'absent' }
    }
    }
  end

  it 'configures arbitrary mistral configurations' do
    is_expected.to contain_mistral_config('DEFAULT/foo').with_value('fooValue')
    is_expected.to contain_mistral_config('DEFAULT/bar').with_value('barValue')
    is_expected.to contain_mistral_config('DEFAULT/baz').with_ensure('absent')
  end

end