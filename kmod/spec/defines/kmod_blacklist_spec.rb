require 'spec_helper'

describe 'kmod::blacklist', :type => :define do
  let(:title) { 'foo' }
  context 'when ensure is set to present' do
    let(:params) do { :ensure => 'present', :file => '/bar/baz' } end
    it { should contain_kmod__blacklist('foo') }
    it { should contain_kmod__generic('blacklist foo').with({
      'ensure' => 'present',
      'type'   => 'blacklist',
      'module' => 'foo',
      'file'   => '/bar/baz'
    }) }
  end

  context 'when ensure is set to absent' do
    let(:params) do { :ensure => 'absent', :file => '/bar/baz' } end
    it { should contain_kmod__blacklist('foo') }
    it { should contain_kmod__generic('blacklist foo').with({
      'ensure' => 'absent',
      'type'   => 'blacklist',
      'module' => 'foo',
      'file'   => '/bar/baz'
    }) }
  end
end