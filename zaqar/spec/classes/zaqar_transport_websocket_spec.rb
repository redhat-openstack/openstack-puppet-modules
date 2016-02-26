require 'spec_helper'

describe 'zaqar::transport::websocket' do

  shared_examples_for 'zaqar::transport::websocket' do
    describe 'with custom values' do
      let :params do
        {
          :bind  => '1',
          :port  => '2',
          :external_port  => '3',
        }
      end

      it 'configures custom values' do
        is_expected.to contain_zaqar_config('drivers:transport:websocket/bind').with_value('1')
        is_expected.to contain_zaqar_config('drivers:transport:websocket/port').with_value('2')
        is_expected.to contain_zaqar_config('drivers:transport:websocket/external-port').with_value('3')
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

      it_configures 'zaqar::transport::websocket'
    end
  end
end
