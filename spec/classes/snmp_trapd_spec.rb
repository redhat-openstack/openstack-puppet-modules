require 'spec_helper'

describe 'snmp::trapd' do

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
        it { should contain_file('snmptrapd.conf').with(
          :ensure => 'present',
          :path   => '/etc/snmp/snmptrapd.conf'
        )}
        it { should contain_file('snmptrapd.sysconfig').with(
          :ensure => 'present',
          :path   => '/etc/sysconfig/snmptrapd'
        )}
        it { should contain_service('snmptrapd').with(
          :ensure => 'running',
          :enable => true,
          :name   => 'snmptrapd'
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
        it { should contain_file('snmptrapd.conf').with(
          :ensure => 'present',
          :path   => '/etc/snmp/snmptrapd.conf'
        )}
        it { should contain_file('snmptrapd.sysconfig').with(
          :ensure => 'present',
          :path   => '/etc/default/snmptrapd'
        )}
        it { should contain_service('snmptrapd').with(
          :ensure => 'running',
          :enable => true,
          :name   => 'snmptrapd'
        )}
      end
    end
  end

  describe 'on a supported operatingsystem, with custom settings' do
    redhatish.each do |os|
      describe "for operating system #{os}" do
        let(:params) {
          {
            :service_name   => 'snmp-trapserver',
            :service_ensure => 'stopped',
            :service_enable => false
          }
        }
        let :facts do {
          :lsbmajdistrelease => '6',
          :operatingsystem   => os
        }
        end
        it { should contain_file('snmptrapd.conf').with(
          :ensure => 'present',
          :path   => '/etc/snmp/snmptrapd.conf'
        )}
        it { should contain_file('snmptrapd.sysconfig').with(
          :ensure => 'present',
          :path   => '/etc/sysconfig/snmptrapd'
        )}
        it { should contain_service('snmptrapd').with(
          :ensure => 'stopped',
          :enable => false,
          :name   => 'snmp-trapserver'
        )}
      end
    end
    debianish.each do |os|
      describe "for operating system #{os}" do
        let(:params) {
          {
            :service_name   => 'snmp-trapserver',
            :service_ensure => 'stopped',
            :service_enable => false
          }
        }
        let :facts do {
          :operatingsystem   => os
        }
        end
        it { should contain_file('snmptrapd.conf').with(
          :ensure => 'present',
          :path   => '/etc/snmp/snmptrapd.conf'
        )}
        it { should contain_file('snmptrapd.sysconfig').with(
          :ensure => 'present',
          :path   => '/etc/default/snmptrapd'
        )}
        it { should contain_service('snmptrapd').with(
          :ensure => 'stopped',
          :enable => false,
          :name   => 'snmp-trapserver'
        )}
      end
    end
  end
end

