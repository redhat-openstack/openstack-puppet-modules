require 'spec_helper'
describe 'zaqar' do

  let :pre_condition do
    "zaqar::server_instance{ '1': transport => 'websocket' }"
  end

  let :facts do
    { :osfamily => 'RedHat' }
  end

  let :params do
    { :admin_password => 'foo' }
  end

  describe 'with a websocket server instance 1' do

    it { is_expected.to contain_service('openstack-zaqar@1').with(
        :ensure => 'running',
        :enable => true
    )}
    it {is_expected.to contain_file('/etc/zaqar/1.conf') }

  end

end
