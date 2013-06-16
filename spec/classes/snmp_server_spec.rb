require 'spec_helper'

describe 'snmp::server' do

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
#        it { should contain_package('snmpd').with(
#          :ensure => 'present',
#          :name   => 'net-snmp'
#        )}
        it { should contain_file('snmpd.conf').with(
          :ensure => 'present',
          :path   => '/etc/snmp/snmpd.conf'
        )}
        it { should contain_file('snmpd.sysconfig').with(
          :ensure => 'present',
          :path   => '/etc/sysconfig/snmpd'
        )}
        it { should contain_service('snmpd').with(
          :ensure => 'running',
          :enable => true,
          :name   => 'snmpd'
        )}
      end
    end

    debianish.each do |os|
      describe "for operating system #{os}" do
        let(:params) {{}}
        let :facts do {
          :operatingsystem => os
        }
        end
        it { should contain_file('snmpd.conf').with(
          :ensure => 'present',
          :path   => '/etc/snmp/snmpd.conf'
        )}
        it { should contain_file('snmpd.sysconfig').with(
          :ensure => 'present',
          :path   => '/etc/default/snmp'
        )}
        it { should contain_service('snmpd').with(
          :ensure => 'running',
          :enable => true,
          :name   => 'snmpd'
        )}
      end
    end
  end

  describe 'on a supported operatingsystem, with custom settings' do
    redhatish.each do |os|
      describe "for operating system #{os}" do
        let(:params) {
          {
            :autoupgrade    => true,
            :package_name   => 'snmp-server',
            :service_ensure => 'stopped',
            :service_enable => false
          }
        }
        let :facts do {
          :lsbmajdistrelease => '6',
          :operatingsystem   => os
        }
        end
#        it { should contain_package('snmpd').with(
#          :ensure => 'latest',
#          :name   => 'net-snmp'
#        )}
        it { should contain_file('snmpd.conf').with(
          :ensure => 'present',
          :path   => '/etc/snmp/snmpd.conf'
        )}
        it { should contain_file('snmpd.sysconfig').with(
          :ensure => 'present',
          :path   => '/etc/sysconfig/snmpd'
        )}
        it { should contain_service('snmpd').with(
          :ensure => 'stopped',
          :enable => false,
          :name   => 'snmpd'
        )}
      end
    end
    debianish.each do |os|
      describe "for operating system #{os}" do
        let(:params) {
          {
            :autoupgrade    => true,
            :package_name   => 'snmp-server',
            :service_ensure => 'stopped',
            :service_enable => false
          }
        }
        let :facts do {
          :operatingsystem   => os
        }
        end
        it { should contain_file('snmpd.conf').with(
          :ensure => 'present',
          :path   => '/etc/snmp/snmpd.conf'
        )}
        it { should contain_file('snmpd.sysconfig').with(
          :ensure => 'present',
          :path   => '/etc/default/snmp'
        )}
        it { should contain_service('snmpd').with(
          :ensure => 'stopped',
          :enable => false,
          :name   => 'snmpd'
        )}
      end
    end
  end
end
