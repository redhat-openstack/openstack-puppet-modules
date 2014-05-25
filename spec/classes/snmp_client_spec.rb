#!/usr/bin/env rspec

require 'spec_helper'

describe 'snmp::client', :type => 'class' do

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
  suseish = ['Suse']
  freebsdish = ['FreeBSD']

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
          :require => 'Package[snmp-client]'
        )}
      end
    end

    debianish.each do |os|
      describe "for osfamily Debian, operatingsystem #{os}" do
        let(:params) {{}}
        let :facts do {
          :osfamily        => 'Debian',
          :operatingsystem => os,
          :operatingsystemrelease => '6.0.7'
        }
        end
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
          :require => 'Package[snmp-client]'
        )}
      end
    end

    suseish.each do |os|
      describe "for osfamily Suse, operatingsystem #{os}" do
        let(:params) {{}}
        let :facts do {
          :osfamily               => 'Suse',
          :operatingsystem        => os,
          :operatingsystemrelease => '11.1'
        }
        end
        it { should_not contain_package('snmp-client') }
        it { should contain_file('snmp.conf').with(
          :ensure  => 'present',
          :mode    => '0644',
          :owner   => 'root',
          :group   => 'root',
          :path    => '/etc/snmp/snmp.conf',
          :require => nil
        )}
      end
    end

    freebsdish.each do |os|
      describe "for osfamily FreeBSD, operatingsystem #{os}" do
        let(:params) {{}}
        let :facts do {
          :osfamily               => 'FreeBSD',
          :operatingsystem        => os,
          :operatingsystemrelease => '9.2'
        }
        end
        it { should contain_package('snmp-client').with(
          :ensure => 'present',
          :name   => 'net-mgmt/net-snmp'
        )}
        it { should_not contain_file('snmp.conf').with(
          :ensure  => 'present',
          :mode    => '0755',
          :owner   => 'root',
          :group   => 'wheel',
          :path    => '/usr/local/etc/snmp/snmp.conf',
          :require => nil
        )}
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
      it { should contain_package('snmp-client').with_ensure('absent') }
      it { should contain_file('snmp.conf').with_ensure('absent') }
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
      it { should contain_package('snmp-client').with_ensure('latest') }
      it { should contain_file('snmp.conf').with_ensure('present') }
    end

    describe 'autoupgrade => badvalue' do
      let(:params) {{ :autoupgrade => 'badvalue' }}
      it 'should fail' do
        expect {
          should raise_error(Puppet::Error, /"badvalue" is not a boolean./)
        }
      end
    end

    describe 'snmp_config => [ "defVersion 2c", "defCommunity public" ]' do
      let(:params) {{ :snmp_config => [ 'defVersion 2c', 'defCommunity public' ] }}
      it { should contain_file('snmp.conf') }
      it 'should contain File[snmp.conf] with contents "defVersion 2c" and "defCommunity public"' do
        verify_contents(subject, 'snmp.conf', [
          'defVersion 2c',
          'defCommunity public',
        ])
      end
    end
  end

end
