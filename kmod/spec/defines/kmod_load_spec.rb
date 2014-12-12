require 'spec_helper'

describe 'kmod::load', :type => :define do
  let(:title) { 'foo' }
  context 'with ensure set to present' do
    let(:params) do { :ensure => 'present', :file => '/foo/bar' } end
    it { should contain_kmod__load('foo') }
    it { should contain_exec('modprobe foo').with({'unless' => "egrep -q '^foo ' /proc/modules"}) }

    context 'on Debian derivatives' do
    let(:facts) do { :osfamily => 'Debian' } end
      it { should contain_augeas('Manage foo in /foo/bar').with({
        'incl'    => '/foo/bar',
        'lens'    => 'Modules.lns',
        'changes' => "clear 'foo'"
      }) }
    end

    context 'on redhat derivatives' do
    let(:facts) do { :osfamily => 'RedHat' } end
    it { should contain_file('/etc/sysconfig/modules/foo.modules').with({
      'ensure'  => 'present',
      'mode'    => '0755',
      'content' => /exec \/sbin\/modprobe foo > \/dev\/null 2>&1/
    })}
    end
  end

  context 'with ensure set to absent' do
    let(:params) do { :ensure => 'absent', :file => '/foo/bar' } end
    it { should contain_kmod__load('foo') }
    it { should contain_exec('modprobe -r foo').with({ 'onlyif' => "egrep -q '^foo ' /proc/modules" }) }

    context 'on Debian derivatives' do
      let(:facts) do { :osfamily => 'Debian' } end
      it { should contain_augeas('Manage foo in /foo/bar').with({
        'incl'    => '/foo/bar',
        'lens'    => 'Modules.lns',
        'changes' => "rm 'foo'"
      })}
    end

    context 'on redhat derivatives' do
    let(:facts) do { :osfamily => 'RedHat' } end
    it { should contain_file('/etc/sysconfig/modules/foo.modules').with({
      'ensure'  => 'absent',
      'mode'    => '0755',
      'content' => /exec \/sbin\/modprobe foo > \/dev\/null 2>&1/
    })}
    end
  end
end