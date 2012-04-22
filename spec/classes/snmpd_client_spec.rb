require 'spec_helper'

describe 'snmpd::client' do

  describe 'on a non-supported operatingsystem' do
    let(:params) {{}}
    let :facts do {
      :operatingsystem => 'foo'
    }
    end
    it 'should fail' do
      expect do
        subject
      end.should raise_error(/Module snmpd is not supported on foo/)
    end
  end

  redhatish = ['RedHat', 'CentOS', 'Scientific', 'SLC', 'OracleLinux', 'OEL']
  fedoraish = ['Fedora']

  describe 'on a supported operatingsystem, with default settings' do
    redhatish.each do |os|
      describe "for operating system #{os}" do
        let(:params) {{}}
        let :facts do {
          :lsbmajdistrelease => '6',
          :operatingsystem   => os
        }
        end
        it { should contain_package('snmp-client').with(
          :ensure => 'present',
          :name   => 'net-snmp-utils'
        )}
        it { should contain_file('snmp.conf').with(
          :ensure => 'present',
          :path   => '/etc/snmp/snmp.conf'
        )}
      end
    end
  end

  describe 'on a supported operatingsystem, with custom settings' do
    redhatish.each do |os|
      describe "for operating system #{os}" do
        let(:params) {
          {
#            :ensure       => 'present',
            :autoupgrade  => true,
            :package_name => 'snmp-client'
          }
        }
        let :facts do {
          :lsbmajdistrelease => '6',
          :operatingsystem   => os
        }
        end
        it { should contain_package('snmp-client').with(
          :ensure => 'latest',
          :name   => 'snmp-client'
        )}
        it { should contain_file('snmp.conf').with(
          :ensure => 'present',
          :path   => '/etc/snmp/snmp.conf'
        )}
      end
    end
  end
end
