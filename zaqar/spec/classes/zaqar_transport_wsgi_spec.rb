require 'spec_helper'

describe 'zaqar::transport::wsgi' do

  shared_examples_for 'zaqar::transport::wsgi' do
    describe 'with custom values' do
      let :params do
        {
          :bind  => '1',
          :port  => '2',
        }
      end

      it 'configures custom values' do
        is_expected.to contain_zaqar_config('drivers:transport:wsgi/bind').with_value('1')
        is_expected.to contain_zaqar_config('drivers:transport:wsgi/port').with_value('2')
      end
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_configures 'zaqar::transport::wsgi'
    end
  end
end
