#!/usr/bin/env rspec

require 'spec_helper'

describe 'snmp::server', :type => 'class' do

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
        it { should contain_file('snmpd.conf').with(
          :ensure  => 'present',
          :mode    => '0644',
          :owner   => 'root',
          :group   => 'root',
          :path    => '/etc/snmp/snmpd.conf',
          :require => 'Package[snmpd]',
          :notify  => 'Service[snmpd]'
        )}
        # TODO add more contents for File[snmpd.conf]
        it 'should contain File[snmpd.conf] with contents "syslocation Unknown" and "syscontact Unknown"' do
          verify_contents(subject, 'snmpd.conf', [
            'syslocation Unknown',
            'syscontact Unknown',
          ])
        end
        it { should contain_file('snmpd.sysconfig').with(
          :ensure  => 'present',
          :mode    => '0644',
          :owner   => 'root',
          :group   => 'root',
          :path    => '/etc/sysconfig/snmpd',
          :require => 'Package[snmpd]',
          :notify  => 'Service[snmpd]'
        )}
#        it 'should contain File[snmpd.sysconfig] with contents "syscontact = Unknown"' do
#          verify_contents(subject, 'snmpd.sysconfig', [
#            'syscontact = Unknown',
#          ])
#        end
        it { should contain_service('snmpd').with(
          :ensure     => 'running',
          :name       => 'snmpd',
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
        it { should contain_file('snmpd.conf').with(
          :ensure  => 'present',
          :mode    => '0600',
          :owner   => 'root',
          :group   => 'root',
          :path    => '/etc/snmp/snmpd.conf',
          :require => 'Package[snmpd]',
          :notify  => 'Service[snmpd]'
        )}
        it 'should contain File[snmpd.conf] with contents "syslocation Unknown" and "syscontact Unknown"' do
          verify_contents(subject, 'snmpd.conf', [
            'syslocation Unknown',
            'syscontact Unknown',
          ])
        end
        it { should contain_file('snmpd.sysconfig').with(
          :ensure  => 'present',
          :mode    => '0644',
          :owner   => 'root',
          :group   => 'root',
          :path    => '/etc/default/snmp',
          :require => 'Package[snmpd]',
          :notify  => 'Service[snmpd]'
        )}
#        it 'should contain File[snmpd.sysconfig] with contents "syscontact = Unknown"' do
#          verify_contents(subject, 'snmpd.sysconfig', [
#            'syscontact = Unknown',
#          ])
#        end
        it { should contain_service('snmpd').with(
          :ensure     => 'running',
          :name       => 'snmpd',
          :enable     => true,
          :hasstatus  => true,
          :hasrestart => true,
          :require    => [ 'Package[snmpd]', 'File[var-net-snmp]', ]
        )}
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
      it { should contain_file('snmpd.conf').with_ensure('absent') }
      it { should contain_file('snmpd.sysconfig').with_ensure('absent') }
      it { should contain_service('snmpd').with_ensure('stopped') }
    end

    describe 'ensure => badvalue' do
      let(:params) {{ :ensure => 'badvalue' }}
      it 'should fail' do
        expect {
          should raise_error(Puppet::Error, /ensure parameter must be present or absent/)
        }
      end
    end

    # TODO remove autoupgrade
    describe 'autoupgrade => true' do
      let(:params) {{ :autoupgrade => true }}
      it { should contain_file('snmpd.conf').with_ensure('present') }
      it { should contain_file('snmpd.sysconfig').with_ensure('present') }
      it { should contain_service('snmpd').with_ensure('running') }
    end

    describe 'autoupgrade => badvalue' do
      let(:params) {{ :autoupgrade => 'badvalue' }}
      it 'should fail' do
        expect {
          should raise_error(Puppet::Error, /"badvalue" is not a boolean./)
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
