require 'spec_helper'

describe 'snmp' do

  describe 'on a non-supported operatingsystem' do
    let(:params) {{}}
    let :facts do {
      :operatingsystem => 'foo'
    }
    end
    it 'should fail' do
      expect do
        subject
      end.to raise_error(/Module snmp is not supported on foo/)
    end
  end

  redhatish = ['RedHat']
  debianish = ['Ubuntu']

  describe 'on a supported operatingsystem, with default settings' do
    redhatish.each do |os|
      describe "for operating system #{os}" do
        let(:params) {{}}
        let :facts do {
          :lsbmajdistrelease => '6',
          :operatingsystem   => os
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
          :ensure => 'present',
          :path   => '/etc/snmp/snmp.conf'
        )}
        it { should contain_file('var-net-snmp').with(
          :ensure => 'directory',
          :path   => '/var/lib/net-snmp'
        )}
      end
    end
    debianish.each do |os|
      describe "for operating system #{os}" do
        let(:params) {{}}
        let :facts do {
          :operatingsystem   => os
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
          :ensure => 'present',
          :path   => '/etc/snmp/snmp.conf'
        )}
        it { should contain_file('var-net-snmp').with(
          :ensure => 'directory',
          :path   => '/var/lib/snmp'
        )}
      end
    end
  end

  describe 'on a supported operatingsystem, with custom settings' do
    redhatish.each do |os|
      describe "for operating system #{os}" do
        let(:params) {
          {
            :ensure       => 'present',
            :autoupgrade  => true,
          }
        }
        let :facts do {
          :lsbmajdistrelease => '6',
          :operatingsystem   => os
        }
        end
        it { should contain_package('snmpd').with(
          :ensure => 'latest',
          :name   => 'net-snmp'
        )}
        it { should contain_package('snmp-client').with(
          :ensure => 'latest',
          :name   => 'net-snmp-utils'
        )}
        it { should contain_file('snmp.conf').with(
          :ensure => 'present',
          :path   => '/etc/snmp/snmp.conf'
        )}
        it { should contain_file('var-net-snmp').with(
          :ensure => 'directory',
          :path   => '/var/lib/net-snmp'
        )}
      end
    end
    debianish.each do |os|
      describe "for operating system #{os}" do
        let(:params) {
          {
            :ensure       => 'present',
            :autoupgrade  => true,
          }
        }
        let :facts do {
          :operatingsystem   => os
        }
        end
        it { should contain_package('snmpd').with(
          :ensure => 'latest',
          :name   => 'snmpd'
        )}
        it { should contain_package('snmp-client').with(
          :ensure => 'latest',
          :name   => 'snmp'
        )}
        it { should contain_file('snmp.conf').with(
          :ensure => 'present',
          :path   => '/etc/snmp/snmp.conf'
        )}
        it { should contain_file('var-net-snmp').with(
          :ensure => 'directory',
          :path   => '/var/lib/snmp'
        )}
      end
    end
  end
end
