require 'spec_helper'
describe 'types::service' do

  context 'service with bare minimum specified' do
    let(:title) { 'service_minimum' }
    it {
      should contain_service('service_minimum').with({
        'ensure' => 'running',
        'enable' => 'true',
      })
    }
  end

  context 'service with all options specified' do
    let(:title) { 'service_maximum' }
    let(:params) do
      {
        :ensure     => 'stopped',
        :binary     => '/bin/true',
        :control    => 'SERVICE_MAXIMUM_START',
        :enable     => 'manual',
        :hasrestart => 'true',
        :hasstatus  => 'false',
        :manifest   => '/bin/manifest',
        :path       => '/etc/init.d',
        :pattern    => 'service_maximum',
        :provider   => 'init',
        :restart    => '/bin/restart',
        :start      => '/bin/start',
        :status     => '/bin/status',
        :stop       => '/bin/stop',
      }
    end

    it {
      should contain_service('service_maximum').with({
        'ensure'     => 'stopped',
        'binary'     => '/bin/true',
        'control'    => 'SERVICE_MAXIMUM_START',
        'enable'     => 'manual',
        'hasrestart' => 'true',
        'hasstatus'  => 'false',
        'manifest'   => '/bin/manifest',
        'path'       => '/etc/init.d',
        'pattern'    => 'service_maximum',
        'provider'   => 'init',
        'restart'    => '/bin/restart',
        'start'      => '/bin/start',
        'status'     => '/bin/status',
        'stop'       => '/bin/stop',
      })
    }
  end

  context 'service with invalid ensure' do
    let(:title) { 'invalid' }
    let(:params) do
      {
        :ensure  => 'invalid',
      }
    end

    it 'should fail' do
      expect {
        should contain_class('types')
      }.to raise_error(Puppet::Error,/types::service::invalid::ensure can only be <stopped>, <false>, <running> or <true> and is set to <invalid>/)
    end
  end

  context 'service with invalid enable' do
    let(:title) { 'invalid' }
    let(:params) do
      {
        :enable  => 'invalid',
      }
    end

    it 'should fail' do
      expect {
        should contain_class('types')
      }.to raise_error(Puppet::Error,/types::service::invalid::enable can only be <true>, <false> or <manual> and is set to <invalid>/)
    end
  end

end
