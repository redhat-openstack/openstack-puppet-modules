require 'spec_helper'

describe 'snmpd::snmpv3_user' do
  let :facts do {
    :lsbmajdistrelease => '6',
    :operatingsystem   => 'CentOS'
  }
  end

#  let(:title) { 'myuser' }
#
#  let :params do {
#      :authpass => 'myauthpass',
#      :authtype => 'MD5',
#      :privpass => 'myprivpass',
#      :privtype => 'DES'
#  }
#  end
#
#  it { should contain_exec('create-snmpv3-user-myuser').with(
#    :command => 'service snmpd stop ; echo "createUser myuser MD5 myauthpass DES myprivpass" >>/var/lib/net-snmp/snmpd.conf && touch /var/lib/net-snmp/myuser',
#    :require => [ 'Package[snmpd]', 'File[var-net-snmp]' ],
#    :before  => 'Service[snmpd]'
#  )}

  describe 'with default settings' do
    let(:title) { 'myDEFAULTuser' }

    let :params do {
        :authpass => 'myauthpass',
    }
    end

    it { should contain_exec('create-snmpv3-user-myDEFAULTuser').with(
      :command => 'service snmpd stop ; echo "createUser myDEFAULTuser SHA myauthpass" >>/var/lib/net-snmp/snmpd.conf && touch /var/lib/net-snmp/myDEFAULTuser',
      :creates => '/var/lib/net-snmp/myDEFAULTuser',
      :require => [ 'Package[snmpd]', 'File[var-net-snmp]' ],
      :before  => 'Service[snmpd]'
    )}
  end

  describe 'with all settings' do
    let(:title) { 'myALLuser' }

    let :params do {
        :authpass => 'myauthpass',
        :authtype => 'MD5',
        :privpass => 'myprivpass',
        :privtype => 'DES'
    }
    end

    it { should contain_exec('create-snmpv3-user-myALLuser').with(
      :command => 'service snmpd stop ; echo "createUser myALLuser MD5 myauthpass DES myprivpass" >>/var/lib/net-snmp/snmpd.conf && touch /var/lib/net-snmp/myALLuser',
      :creates => '/var/lib/net-snmp/myALLuser',
      :require => [ 'Package[snmpd]', 'File[var-net-snmp]' ],
      :before  => 'Service[snmpd]'
    )}
  end
end
