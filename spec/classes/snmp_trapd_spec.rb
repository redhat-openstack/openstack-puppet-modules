#!/usr/bin/env rspec

require 'spec_helper'

describe 'snmp::trapd', :type => 'class' do

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
        it { should contain_file('snmptrapd.conf').with(
          :ensure  => 'present',
          :mode    => '0644',
          :owner   => 'root',
          :group   => 'root',
          :path    => '/etc/snmp/snmptrapd.conf',
          :require => 'Package[snmpd]',
          :notify  => 'Service[snmptrapd]'
        )}
        it 'should contain File[snmptrapd.conf] with correct contents' do
          verify_contents(subject, 'snmptrapd.conf', [
            'authCommunity   log,execute,net public',
          ])
        end
        it { should contain_file('snmptrapd.sysconfig').with(
          :ensure  => 'present',
          :mode    => '0644',
          :owner   => 'root',
          :group   => 'root',
          :path    => '/etc/sysconfig/snmptrapd',
          :require => 'Package[snmpd]',
          :notify  => 'Service[snmptrapd]'
        )}
        it { should contain_service('snmptrapd').with(
          :ensure     => 'running',
          :name       => 'snmptrapd',
          :enable     => true,
          :hasstatus  => true,
          :hasrestart => true,
          :require    => [ 'Package[snmpd]', 'File[var-net-snmp]', ]
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
        it { should contain_file('snmptrapd.conf').with(
          :ensure  => 'present',
          :mode    => '0600',
          :owner   => 'root',
          :group   => 'root',
          :path    => '/etc/snmp/snmptrapd.conf',
          :require => 'Package[snmpd]',
          :notify  => nil
        )}
        it 'should contain File[snmptrapd.conf] with correct contents' do
          verify_contents(subject, 'snmptrapd.conf', [
            'authCommunity   log,execute,net public',
          ])
        end
        it { should_not contain_file('snmptrapd.sysconfig') }
#        it { should contain_file('snmptrapd.sysconfig').with(
#          :ensure  => 'present',
#          :mode    => '0644',
#          :owner   => 'root',
#          :group   => 'root',
#          :path    => '/etc/default/snmp',
#          :require => 'Package[snmpd]',
#          :notify  => 'Service[snmptrapd]'
#        )}
        it { should_not contain_service('snmptrapd') }
#        it { should contain_service('snmptrapd').with(
#          :ensure     => 'running',
#          :name       => 'snmptrapd',
#          :enable     => true,
#          :hasstatus  => true,
#          :hasrestart => true,
#          :require    => [ 'Package[snmpd]', 'File[var-net-snmp]', ]
#        )}
      end
    end
  end

  context 'on a supported osfamily, with custom parameters' do
    let :facts do {
      :osfamily          => 'RedHat',
      :lsbmajdistrelease => '6'
    }
    end

    describe 'ensure => absent' do
      let(:params) {{ :ensure => 'absent' }}
      it { should contain_file('snmptrapd.conf').with_ensure('absent') }
      it { should contain_file('snmptrapd.sysconfig').with_ensure('absent') }
      it { should contain_service('snmptrapd').with_ensure('stopped') }
    end

    describe 'ensure => badvalue' do
      let(:params) {{ :ensure => 'badvalue' }}
      it 'should fail' do
        expect {
          should raise_error(Puppet::Error, /ensure parameter must be present or absent/)
        }
      end
    end

    describe 'service_ensure => badvalue' do
      let(:params) {{ :service_ensure => 'badvalue' }}
      it 'should fail' do
        expect {
          should raise_error(Puppet::Error, /service_ensure parameter must be running or stopped/)
        }
      end
    end
  end

end
