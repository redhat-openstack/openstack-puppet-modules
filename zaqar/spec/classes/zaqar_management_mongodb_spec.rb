require 'spec_helper'

describe 'zaqar::management::mongodb' do

  let :req_params do
    {
      :uri   => 'mongodb://127.0.0.1:27017',
    }
  end

  let :facts do
    { :osfamily => 'RedHat' }
  end

  describe 'with only required params' do
    let :params do
      req_params
    end

    it 'should config mongo management driver' do
      is_expected.to contain_zaqar_config('drivers/management_store').with(
       :value => 'mongodb'
      )
      is_expected.to contain_zaqar_config('drivers:management_store:mongodb/uri').with(
       :value => 'mongodb://127.0.0.1:27017'
      )
    end

  end

  describe 'with custom values' do
    let :params do
      req_params.merge!({
        :ssl_keyfile  => 'keyfile',
        :ssl_certfile  => 'certfile',
        :ssl_cert_reqs  => 'cert_reqs',
        :ssl_ca_certs  => 'ca_certs',
        :database  => 'zaqar_db',
        :max_attempts  => '1',
        :max_retry_sleep => '2',
        :max_retry_jitter => '3',
        :max_reconnect_attempts => '4',
        :reconnect_sleep => '5',
      })
    end

    it 'configures custom values' do
      is_expected.to contain_zaqar_config('drivers:management_store:mongodb/ssl_keyfile').with_value('keyfile')
      is_expected.to contain_zaqar_config('drivers:management_store:mongodb/ssl_certfile').with_value('certfile')
      is_expected.to contain_zaqar_config('drivers:management_store:mongodb/ssl_cert_reqs').with_value('cert_reqs')
      is_expected.to contain_zaqar_config('drivers:management_store:mongodb/ssl_ca_certs').with_value('ca_certs')
      is_expected.to contain_zaqar_config('drivers:management_store:mongodb/database').with_value('zaqar_db')
      is_expected.to contain_zaqar_config('drivers:management_store:mongodb/max_attempts').with_value('1')
      is_expected.to contain_zaqar_config('drivers:management_store:mongodb/max_retry_sleep').with_value('2')
      is_expected.to contain_zaqar_config('drivers:management_store:mongodb/max_retry_jitter').with_value('3')
      is_expected.to contain_zaqar_config('drivers:management_store:mongodb/max_reconnect_attempts').with_value('4')
      is_expected.to contain_zaqar_config('drivers:management_store:mongodb/reconnect_sleep').with_value('5')
    end
  end

end
