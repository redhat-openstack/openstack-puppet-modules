require 'spec_helper'
describe 'qdr' do

  it { should contain_package('qpid-dispatch-router').with({ :ensure => :installed }) }    
  it { should contain_package('cyrus-sasl-lib').with({ :ensure => :installed }) }
  it { should contain_package('cyrus-sasl-plain').with({ :ensure => :installed }) }
  it { should contain_package('qpid-dispatch-tools').with({ :ensure => :installed }) }      

  it do
    should contain_file('/var/lib/qdrouterd').with({
      :ensure => :directory,
      :owner  => '0',
      :group  => '0',
      :mode   => '0644',
    })
  end  
  
  it do
    should contain_file('/etc/qpid-dispatch').with({
      :ensure => :directory,
      :owner  => '0',
      :group  => '0',
      :mode   => '0644',
    })
  end
  
  it do
    should contain_file('qdrouterd.conf').with({
      :ensure => :file,
      :owner  => '0',
      :group  => '0',
      :mode   => '0644',
    })
  end
  
  it do
    should contain_service('qdrouterd').with({
      :ensure => 'running',
      :enable => 'true',
    })
  end
end
