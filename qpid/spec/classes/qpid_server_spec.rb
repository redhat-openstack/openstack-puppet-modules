require 'spec_helper'

describe 'qpid::server' do

  it do
    should contain_file('/etc/qpidd.conf').with_content(
      /^port=5672$/
    ).with_content(
      /^max-connections=65530$/
    ).with_content(
      /^worker-threads=17$/
    ).with_content(
      /^connection-backlog=10$/
    ).with_content(
      /^auth=no$/
    ).with_content(
      /^realm=QPID$/
    ).with_content(
      /^data-dir=\/var\/lib\/qpidd$/
    ).with({
      :ensure => :present,
      :owner  => 'root',
      :group  => 'root',
      :mode   => '644',
    })
  end

  it { should contain_package('qpid-cpp-server').with({ :ensure => :present }) }

  it do
    should contain_service('qpidd').with({
      :ensure => 'running',
      :enable => 'true',
    })
  end

end
