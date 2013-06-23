#!/usr/bin/env rspec

require 'spec_helper'

describe 'snmp', :type => 'class' do

  context 'on a non-supported osfamily' do
    let(:params) {{}}
    let :facts do {
      :osfamily        => 'foo',
      :operatingsystem => 'bar'
    }
    end
    it 'should fail' do
      expect {
        should raise_error(Puppet::Error, /Module snmp is not supported on bar/)
      }
    end
  end

  redhatish = ['RedHat', 'Fedora']
  debianish = ['Debian', 'Ubuntu']

  context 'on a supported osfamily, default parameters' do
    redhatish.each do |os|
      describe "for osfamily RedHat, operatingsystem #{os}" do
        let(:params) {{}}
        let :facts do {
          :osfamily          => 'RedHat',
          :operatingsystem   => os,
          :lsbmajdistrelease => '6'
        }
        end
        it { should contain_package('snmpd').with(
          :ensure => 'present',
          :name   => 'net-snmp'
        )}
        it { should contain_package('snmp-client').with(
          :ensure => 'present',
          :name   => 'net-snmp-utils'
        )}
        it { should contain_file('snmp.conf').with(
          :ensure  => 'present',
          :mode    => '0644',
          :owner   => 'root',
          :group   => 'root',
          :path    => '/etc/snmp/snmp.conf',
          :require => 'Package[snmpd]'
        )}
        it { should contain_file('var-net-snmp').with(
          :ensure  => 'directory',
          :mode    => '0755',
          :owner   => 'root',
          :group   => 'root',
          :path    => '/var/lib/net-snmp',
          :require => 'Package[snmpd]'
        )}
      end
    end

    debianish.each do |os|
      describe "for osfamily Debian, operatingsystem #{os}" do
        let(:params) {{}}
        let :facts do {
          :osfamily        => 'Debian',
          :operatingsystem => os
        }
        end
        it { should contain_package('snmpd').with(
          :ensure => 'present',
          :name   => 'snmpd'
        )}
        it { should contain_package('snmp-client').with(
          :ensure => 'present',
          :name   => 'snmp'
        )}
        it { should contain_file('snmp.conf').with(
          :ensure  => 'present',
          :mode    => '0644',
          :owner   => 'root',
          :group   => 'root',
          :path    => '/etc/snmp/snmp.conf',
          :require => 'Package[snmpd]'
        )}
        it { should contain_file('var-net-snmp').with(
          :ensure  => 'directory',
          :mode    => '0755',
          :owner   => 'snmp',
          :group   => 'snmp',
          :path    => '/var/lib/snmp',
          :require => 'Package[snmpd]'
        )}
      end
    end
  end

  context 'on a supported osfamily, custom parameters' do
    let :facts do {
      :osfamily          => 'RedHat',
      :operatingsystem   => 'RedHat',
      :lsbmajdistrelease => '6'
    }
    end

    describe 'ensure => absent' do
      let(:params) {{ :ensure => 'absent' }}
      it { should contain_package('snmpd').with_ensure('absent') }
      it { should contain_package('snmp-client').with_ensure('absent') }
      it { should contain_file('snmp.conf').with_ensure('absent') }
      it { should contain_file('var-net-snmp').with_ensure('directory') }
    end

    describe 'autoupgrade => true' do
      let(:params) {{ :autoupgrade => true }}
      it { should contain_package('snmpd').with_ensure('latest') }
      it { should contain_package('snmp-client').with_ensure('latest') }
      it { should contain_file('snmp.conf').with_ensure('present') }
      it { should contain_file('var-net-snmp').with_ensure('directory') }
    end
  end

end
