require 'spec_helper'

describe 'kmod::install', :type => :define do
  context 'install foo module' do
    let(:title) { 'foo' }
    let(:params) do { :ensure => 'present', :command => '/bin/true', :file => '/etc/modprobe.d/modprobe.conf' } end
    it { should contain_kmod__install('foo') }
    it { should contain_kmod__generic('install foo').with({
      'ensure'  => 'present',
      'type'    => 'install',
      'module'  => 'foo',
      'command' => '/bin/true',
      'file'    => '/etc/modprobe.d/modprobe.conf'
    }) }
  end
end


