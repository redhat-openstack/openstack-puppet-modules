require 'spec_helper'

describe 'zaqar::transport::wsgi' do

  let :facts do
    { :osfamily => 'RedHat' }
  end

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
