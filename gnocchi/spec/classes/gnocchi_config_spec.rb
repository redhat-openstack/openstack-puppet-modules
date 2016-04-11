require 'spec_helper'

describe 'gnocchi::config' do

  let :params do
    { :gnocchi_config => {
        'DEFAULT/foo' => { 'value'  => 'fooValue' },
        'DEFAULT/bar' => { 'value'  => 'barValue' },
        'DEFAULT/baz' => { 'ensure' => 'absent' }
      },
      :gnocchi_api_paste_ini => {
        'DEFAULT/foo2' => { 'value'  => 'fooValue' },
        'DEFAULT/bar2' => { 'value'  => 'barValue' },
        'DEFAULT/baz2' => { 'ensure' => 'absent' }
      }
    }
  end

  shared_examples_for 'gnocchi-config' do
    it 'configures arbitrary gnocchi configurations' do
      is_expected.to contain_gnocchi_config('DEFAULT/foo').with_value('fooValue')
      is_expected.to contain_gnocchi_config('DEFAULT/bar').with_value('barValue')
      is_expected.to contain_gnocchi_config('DEFAULT/baz').with_ensure('absent')
    end

    it 'configures arbitrary gnocchi-api-paste configurations' do
      is_expected.to contain_gnocchi_api_paste_ini('DEFAULT/foo2').with_value('fooValue')
      is_expected.to contain_gnocchi_api_paste_ini('DEFAULT/bar2').with_value('barValue')
      is_expected.to contain_gnocchi_api_paste_ini('DEFAULT/baz2').with_ensure('absent')
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'gnocchi-config'
    end
  end
end
