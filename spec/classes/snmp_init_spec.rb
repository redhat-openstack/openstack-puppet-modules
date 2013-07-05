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

  redhatish = ['RedHat']
  #redhatish = ['RedHat', 'Fedora']
  debianish = ['Debian']
  #debianish = ['Debian', 'Ubuntu']

  context 'on a supported osfamily, default parameters' do
    redhatish.each do |os|
      describe "for osfamily RedHat, operatingsystem #{os}" do
        let(:params) {{}}
        let :facts do {
          :osfamily               => 'RedHat',
          :operatingsystem        => os,
          :operatingsystemrelease => '6.4'
        }
        end
        it { should contain_package('snmpd').with(
          :ensure => 'present',
          :name   => 'net-snmp'
        )}
        it { should_not contain_class('snmp::client') }
        it { should contain_file('var-net-snmp').with(
          :ensure  => 'directory',
          :mode    => '0755',
          :owner   => 'root',
          :group   => 'root',
          :path    => '/var/lib/net-snmp',
          :require => 'Package[snmpd]'
        )}

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
        it 'should contain File[snmpd.sysconfig] with contents "OPTIONS="-LS0-6d -Lf /dev/null -p /var/run/snmpd.pid""' do
          verify_contents(subject, 'snmpd.sysconfig', [
            'OPTIONS="-LS0-6d -Lf /dev/null -p /var/run/snmpd.pid"',
          ])
        end
        it { should contain_service('snmpd').with(
          :ensure     => 'running',
          :name       => 'snmpd',
          :enable     => true,
          :hasstatus  => true,
          :hasrestart => true,
          :require    => [ 'Package[snmpd]', 'File[var-net-snmp]', ]
        )}

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
        it 'should contain File[snmptrapd.sysconfig] with contents "OPTIONS="-Lsd -p /var/run/snmptrapd.pid""' do
          verify_contents(subject, 'snmptrapd.sysconfig', [
            'OPTIONS="-Lsd -p /var/run/snmptrapd.pid"',
          ])
        end
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
          :osfamily               => 'Debian',
          :operatingsystem        => os,
          :operatingsystemrelease => '6.0.7'
        }
        end
        it { should contain_package('snmpd').with(
          :ensure => 'present',
          :name   => 'snmpd'
        )}
        it { should_not contain_class('snmp::client') }
        it { should contain_file('var-net-snmp').with(
          :ensure  => 'directory',
          :mode    => '0755',
          :owner   => 'snmp',
          :group   => 'snmp',
          :path    => '/var/lib/snmp',
          :require => 'Package[snmpd]'
        )}

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
        it 'should contain File[snmpd.sysconfig] with contents "SNMPDOPTS=\'-Lsd -Lf /dev/null -u snmp -g snmp -I -smux -p /var/run/snmpd.pid\'"' do
          verify_contents(subject, 'snmpd.sysconfig', [
            'SNMPDRUN=yes',
            'SNMPDOPTS=\'-Lsd -Lf /dev/null -u snmp -g snmp -I -smux -p /var/run/snmpd.pid\'',
          ])
        end
        it { should contain_service('snmpd').with(
          :ensure     => 'running',
          :name       => 'snmpd',
          :enable     => true,
          :hasstatus  => true,
          :hasrestart => true,
          :require    => [ 'Package[snmpd]', 'File[var-net-snmp]', ]
        )}

        it { should contain_file('snmptrapd.conf').with(
          :ensure  => 'present',
          :mode    => '0600',
          :owner   => 'root',
          :group   => 'root',
          :path    => '/etc/snmp/snmptrapd.conf',
          :require => 'Package[snmpd]',
          :notify  => 'Service[snmpd]'
        )}
        it 'should contain File[snmptrapd.conf] with correct contents' do
          verify_contents(subject, 'snmptrapd.conf', [
            'authCommunity   log,execute,net public',
          ])
        end
        it { should_not contain_file('snmptrapd.sysconfig') }
        it 'should contain File[snmpd.sysconfig] with contents "TRAPDOPTS=\'-Lsd -p /var/run/snmptrapd.pid\'"' do
          verify_contents(subject, 'snmpd.sysconfig', [
            'TRAPDRUN=no',
            'TRAPDOPTS=\'-Lsd -p /var/run/snmptrapd.pid\'',
          ])
        end
        it { should_not contain_service('snmptrapd') }
      end
    end
  end

  context 'on a supported osfamily, custom parameters' do
    let :facts do {
      :osfamily               => 'RedHat',
      :operatingsystem        => 'RedHat',
      :operatingsystemrelease => '6.4'
    }
    end

    describe 'ensure => absent' do
      let(:params) {{ :ensure => 'absent' }}
      it { should contain_package('snmpd').with_ensure('absent') }
      it { should_not contain_class('snmp::client') }
      it { should contain_file('var-net-snmp').with_ensure('directory') }
      it { should contain_file('snmpd.conf').with_ensure('absent') }
      it { should contain_file('snmpd.sysconfig').with_ensure('absent') }
      it { should contain_service('snmpd').with_ensure('stopped') }
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

    describe 'autoupgrade => true' do
      let(:params) {{ :autoupgrade => true }}
      it { should contain_package('snmpd').with_ensure('latest') }
      it { should_not contain_class('snmp::client') }
      it { should contain_file('var-net-snmp').with_ensure('directory') }
      it { should contain_file('snmpd.conf').with_ensure('present') }
      it { should contain_file('snmpd.sysconfig').with_ensure('present') }
      it { should contain_service('snmpd').with_ensure('running') }
      it { should contain_file('snmptrapd.conf').with_ensure('present') }
      it { should contain_file('snmptrapd.sysconfig').with_ensure('present') }
      it { should contain_service('snmptrapd').with_ensure('running') }
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

    describe 'install_client => true' do
      let(:params) {{ :install_client => true }}
      it { should contain_class('snmp::client').with(
        :ensure        => 'present',
        :autoupgrade   => 'false',
        :snmp_config   => ''
      )}
    end

    describe 'install_client => true, snmp_config => [ "defVersion 2c", "defCommunity public" ], ensure => absent, and autoupgrade => true' do
      let :params do {
        :install_client => true,
        :ensure         => 'absent',
        :autoupgrade    => true,
        :snmp_config    => [ 'defVersion 2c', 'defCommunity public' ]
      }
      end
      it { should contain_class('snmp::client').with(
        :ensure        => 'absent',
        :autoupgrade   => 'true',
        :snmp_config   => [ 'defVersion 2c', 'defCommunity public' ]
      )}
    end
  end

end
