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
  suseish = ['Suse']
  freebsdish = ['FreeBSD']

  context 'on a supported osfamily, default parameters' do
    redhatish.each do |os|
      describe "for osfamily RedHat, operatingsystem #{os}" do
        let(:params) {{}}
        let :facts do {
          :osfamily               => 'RedHat',
          :operatingsystem        => os,
          :operatingsystemrelease => '6.4',
          :fqdn                   => 'myhost.localdomain'
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
        it 'should contain File[snmpd.conf] with expected contents' do
          verify_contents(subject, 'snmpd.conf', [
            'agentaddress udp:127.0.0.1:161',
            '#rocommunity public 127.0.0.1',
            'com2sec notConfigUser  default       public',
            'group   notConfigGroup v1            notConfigUser',
            'group   notConfigGroup v2c           notConfigUser',
            'view    systemview    included   .1.3.6.1.2.1.1',
            'view    systemview    included   .1.3.6.1.2.1.25.1.1',
            'access  notConfigGroup ""      any       noauth    exact  systemview none  none',
            'sysLocation Unknown',
            'sysContact Unknown',
            'sysServices 72',
            'sysName myhost.localdomain',
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
        # TODO add more contents for File[snmptrapd.conf]
        it 'should contain File[snmptrapd.conf] with correct contents' do
          verify_contents(subject, 'snmptrapd.conf', [
            'doNotLogTraps no',
            'authCommunity log,execute,net public',
            'disableAuthorization no',
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
          :ensure     => 'stopped',
          :name       => 'snmptrapd',
          :enable     => false,
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
          :operatingsystemrelease => '6.0.7',
          :fqdn                   => 'myhost2.localdomain'
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
        # TODO add more contents for File[snmpd.conf]
        it 'should contain File[snmpd.conf] with expected contents' do
          verify_contents(subject, 'snmpd.conf', [
            'agentaddress udp:127.0.0.1:161',
            '#rocommunity public 127.0.0.1',
            'com2sec notConfigUser  default       public',
            'group   notConfigGroup v1            notConfigUser',
            'group   notConfigGroup v2c           notConfigUser',
            'view    systemview    included   .1.3.6.1.2.1.1',
            'view    systemview    included   .1.3.6.1.2.1.25.1.1',
            'access  notConfigGroup ""      any       noauth    exact  systemview none  none',
            'sysLocation Unknown',
            'sysContact Unknown',
            'sysServices 72',
            'sysName myhost2.localdomain',
          ])
        end
        it { should contain_file('snmpd.sysconfig').with(
          :ensure  => 'present',
          :mode    => '0644',
          :owner   => 'root',
          :group   => 'root',
          :path    => '/etc/default/snmpd',
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
        # TODO add more contents for File[snmptrapd.conf]
        it 'should contain File[snmptrapd.conf] with correct contents' do
          verify_contents(subject, 'snmptrapd.conf', [
            'doNotLogTraps no',
            'authCommunity log,execute,net public',
            'disableAuthorization no',
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

    suseish.each do |os|
      describe "for osfamily RedHat, operatingsystem #{os}" do
        let(:params) {{}}
        let :facts do {
          :osfamily               => 'Suse',
          :operatingsystem        => os,
          :operatingsystemrelease => '11.1',
          :fqdn                   => 'myhost3.localdomain'
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
          :mode    => '0600',
          :owner   => 'root',
          :group   => 'root',
          :path    => '/etc/snmp/snmpd.conf',
          :require => 'Package[snmpd]',
          :notify  => 'Service[snmpd]'
        )}
        # TODO add more contents for File[snmpd.conf]
        it 'should contain File[snmpd.conf] with expected contents' do
          verify_contents(subject, 'snmpd.conf', [
            'agentaddress udp:127.0.0.1:161',
            '#rocommunity public 127.0.0.1',
            'com2sec notConfigUser  default       public',
            'group   notConfigGroup v1            notConfigUser',
            'group   notConfigGroup v2c           notConfigUser',
            'view    systemview    included   .1.3.6.1.2.1.1',
            'view    systemview    included   .1.3.6.1.2.1.25.1.1',
            'access  notConfigGroup ""      any       noauth    exact  systemview none  none',
            'sysLocation Unknown',
            'sysContact Unknown',
            'sysServices 72',
            'sysName myhost3.localdomain',
          ])
        end
        it { should contain_file('snmpd.sysconfig').with(
          :ensure  => 'present',
          :mode    => '0644',
          :owner   => 'root',
          :group   => 'root',
          :path    => '/etc/sysconfig/net-snmp',
          :require => 'Package[snmpd]',
          :notify  => 'Service[snmpd]'
        )}
        it 'should contain File[snmpd.sysconfig] with contents "SNMPD_LOGLEVEL="d""' do
          verify_contents(subject, 'snmpd.sysconfig', [
            'SNMPD_LOGLEVEL="d"',
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
          :notify  => 'Service[snmptrapd]'
        )}
        # TODO add more contents for File[snmptrapd.conf]
        it 'should contain File[snmptrapd.conf] with correct contents' do
          verify_contents(subject, 'snmptrapd.conf', [
            'doNotLogTraps no',
            'authCommunity log,execute,net public',
            'disableAuthorization no',
          ])
        end
        it { should_not contain_file('snmptrapd.sysconfig') }
        it { should contain_exec('install /etc/init.d/snmptrapd').with(
          :command => '/usr/bin/install -o 0 -g 0 -m0755 -p /usr/share/doc/packages/net-snmp/rc.snmptrapd /etc/init.d/snmptrapd',
          :creates => '/etc/init.d/snmptrapd',
          :require => 'Package[snmpd]'
        )}
        it { should contain_service('snmptrapd').with(
          :ensure     => 'stopped',
          :name       => 'snmptrapd',
          :enable     => false,
          :hasstatus  => true,
          :hasrestart => true,
          :require    => [ 'Package[snmpd]', 'File[var-net-snmp]', 'Exec[install /etc/init.d/snmptrapd]', ]
        )}
      end
    end

    freebsdish.each do |os|
      describe "for osfamily FreeBSD, operatingsystem #{os}" do
        let(:params) {{}}
        let :facts do {
          :osfamily               => 'FreeBSD',
          :operatingsystem        => os,
          :operatingsystemrelease => '9.2',
          :fqdn                   => 'myhost4.localdomain'
        }
        end
        it { should contain_package('snmpd').with(
          :ensure => 'present',
          :name   => 'net-mgmt/net-snmp'
        )}
        it { should_not contain_class('snmp::client') }
        it { should contain_file('var-net-snmp').with(
          :ensure  => 'directory',
          :mode    => '0600',
          :owner   => 'root',
          :group   => 'wheel',
          :path    => '/var/net-snmp',
          :require => 'Package[snmpd]'
        )}

        it { should contain_file('snmpd.conf').with(
          :ensure  => 'present',
          :mode    => '0755',
          :owner   => 'root',
          :group   => 'wheel',
          :path    => '/usr/local/etc/snmp/snmpd.conf',
          :require => 'Package[snmpd]',
          :notify  => 'Service[snmpd]'
        )}
        # TODO add more contents for File[snmpd.conf]
        it 'should contain File[snmpd.conf] with expected contents' do
          verify_contents(subject, 'snmpd.conf', [
            'agentaddress udp:127.0.0.1:161',
            '#rocommunity public 127.0.0.1',
            'com2sec notConfigUser  default       public',
            'group   notConfigGroup v1            notConfigUser',
            'group   notConfigGroup v2c           notConfigUser',
            'view    systemview    included   .1.3.6.1.2.1.1',
            'view    systemview    included   .1.3.6.1.2.1.25.1.1',
            'access  notConfigGroup ""      any       noauth    exact  systemview none  none',
            'sysLocation Unknown',
            'sysContact Unknown',
            'sysServices 72',
            'sysName myhost4.localdomain',
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
          :mode    => '0755',
          :owner   => 'root',
          :group   => 'wheel',
          :path    => '/usr/local/etc/snmp/snmptrapd.conf',
          :require => 'Package[snmpd]',
          :notify  => 'Service[snmptrapd]'
        )}
        # TODO add more contents for File[snmptrapd.conf]
        it 'should contain File[snmptrapd.conf] with correct contents' do
          verify_contents(subject, 'snmptrapd.conf', [
            'doNotLogTraps no',
            'authCommunity log,execute,net public',
            'disableAuthorization no',
          ])
        end
        it { should contain_service('snmptrapd').with(
          :ensure     => 'stopped',
          :name       => 'snmptrapd',
          :enable     => false,
          :hasstatus  => true,
          :hasrestart => true,
          :require    => [ 'Package[snmpd]', 'File[var-net-snmp]', ]
        )}
      end
    end
  end

  context 'on a supported osfamily (RedHat), custom parameters' do
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
      it { should contain_service('snmptrapd').with_ensure('stopped') }
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
        :snmp_config   => []
      )}
    end

    describe 'manage_client => true' do
      let(:params) {{ :manage_client => true }}
      it { should contain_class('snmp::client').with(
        :ensure      => 'present',
        :autoupgrade => 'false',
        :snmp_config => []
      )}
    end

    describe 'manage_client => true, snmp_config => [ "defVersion 2c", "defCommunity public" ], ensure => absent, and autoupgrade => true' do
      let :params do {
        :manage_client => true,
        :ensure        => 'absent',
        :autoupgrade   => true,
        :snmp_config   => [ 'defVersion 2c', 'defCommunity public' ]
      }
      end
      it { should contain_class('snmp::client').with(
        :ensure      => 'absent',
        :autoupgrade => 'true',
        :snmp_config => [ 'defVersion 2c', 'defCommunity public' ]
      )}
    end

    describe 'service_ensure => stopped' do
      let(:params) {{ :service_ensure => 'stopped' }}
      it { should contain_service('snmpd').with_ensure('stopped') }
      it { should contain_service('snmptrapd').with_ensure('stopped') }
    end

    describe 'trap_service_ensure => running' do
      let(:params) {{ :trap_service_ensure => 'running' }}
      it { should contain_service('snmpd').with_ensure('running') }
      it { should contain_service('snmptrapd').with_ensure('running') }
    end

    describe 'service_ensure => stopped and trap_service_ensure => running' do
      let :params do {
        :service_ensure      => 'stopped',
        :trap_service_ensure => 'running'
      }
      end
      it { should contain_service('snmpd').with_ensure('stopped') }
      it { should contain_service('snmptrapd').with_ensure('running') }
    end

    describe 'snmpd_options => blah' do
      let(:params) {{ :snmpd_options => 'blah' }}
      it { should contain_file('snmpd.sysconfig') }
      it 'should contain File[snmpd.sysconfig] with contents "OPTIONS=\'blah\'"' do
        verify_contents(subject, 'snmpd.sysconfig', [
          'OPTIONS="blah"',
        ])
      end
    end

    describe 'snmptrapd_options => bleh' do
      let(:params) {{ :snmptrapd_options => 'bleh' }}
      it { should contain_file('snmptrapd.sysconfig') }
      it 'should contain File[snmptrapd.sysconfig] with contents "OPTIONS=\'bleh\'"' do
        verify_contents(subject, 'snmptrapd.sysconfig', [
          'OPTIONS="bleh"',
        ])
      end
    end

    describe 'com2sec => [ SomeString ]' do
      let(:params) {{ :com2sec => [ 'SomeString', ] }}
      it 'should contain File[snmpd.conf] with contents "com2sec SomeString"' do
        verify_contents(subject, 'snmpd.conf', [
          'com2sec SomeString',
        ])
      end
    end

    describe 'groups => [ SomeString ]' do
      let(:params) {{ :groups => [ 'SomeString', ] }}
      it 'should contain File[snmpd.conf] with contents "groups SomeString"' do
        verify_contents(subject, 'snmpd.conf', [
          'group   SomeString',
        ])
      end
    end

    describe 'dlmod => [ SomeString ]' do
      let(:params) {{ :dlmod => [ 'SomeString', ] }}
      it 'should contain File[snmpd.conf] with contents "dlmod SomeString"' do
        verify_contents(subject, 'snmpd.conf', [
          'dlmod SomeString',
        ])
      end
    end

    describe 'agentaddress => [ "1.2.3.4", "8.6.7.5:222" ]' do
      let(:params) {{ :agentaddress => ['1.2.3.4','8.6.7.5:222'] }}
      it 'should contain File[snmpd.conf] with contents "agentaddress 1.2.3.4,8.6.7.5:222"' do
        verify_contents(subject, 'snmpd.conf', [
          'agentaddress 1.2.3.4,8.6.7.5:222',
        ])
      end
    end

    describe 'snmptrapdaddr => [ "5.6.7.8", "2.3.4.5:3333" ]' do
      let(:params) {{ :snmptrapdaddr => ['5.6.7.8','2.3.4.5:3333'] }}
      it 'should contain File[snmptrapd.conf] with contents "snmpTrapdAddr 5.6.7.8,2.3.4.5:3333"' do
        verify_contents(subject, 'snmptrapd.conf', [
          'snmpTrapdAddr 5.6.7.8,2.3.4.5:3333',
        ])
      end
    end

    describe 'snmpd_config => [ "option 1", "option 2", ]' do
      let(:params) {{ :snmpd_config => [ 'option 1', 'option 2', ] }}
      it 'should contain File[snmpd.conf] with contents "option1" and "option 2"' do
        verify_contents(subject, 'snmpd.conf', [
          'option 1',
          'option 2',
        ])
      end
    end

    describe 'snmptrapd_config => [ "option 3", "option 4", ]' do
      let(:params) {{ :snmptrapd_config => [ 'option 3', 'option 4', ] }}
      it 'should contain File[snmptrapd.conf] with contents "option 3" and "option 4"' do
        verify_contents(subject, 'snmptrapd.conf', [
          'option 3',
          'option 4',
        ])
      end
    end
  end

  context 'on a supported osfamily (Debian), custom parameters' do
    let :facts do {
      :osfamily               => 'Debian',
      :operatingsystem        => 'Debian',
      :operatingsystemrelease => '7.0'
    }
    end

    describe 'service_ensure => stopped and trap_service_ensure => running' do
      let :params do {
        :service_ensure      => 'stopped',
        :trap_service_ensure => 'running'
      }
      end
      it { should contain_service('snmpd').with_ensure('running') }
      it { should_not contain_service('snmptrapd') }
      it 'should contain File[snmpd.sysconfig] with contents "SNMPDRUN=no" and "TRAPDRUN=yes"' do
        verify_contents(subject, 'snmpd.sysconfig', [
          'SNMPDRUN=no',
          'TRAPDRUN=yes',
        ])
      end
    end

    describe 'snmpd_options => blah' do
      let(:params) {{ :snmpd_options => 'blah' }}
      it { should contain_file('snmpd.sysconfig') }
      it 'should contain File[snmpd.sysconfig] with contents "SNMPDOPTS=\'blah\'"' do
        verify_contents(subject, 'snmpd.sysconfig', [
          'SNMPDOPTS=\'blah\'',
        ])
      end
    end

    describe 'snmptrapd_options => bleh' do
      let(:params) {{ :snmptrapd_options => 'bleh' }}
      it { should contain_file('snmpd.sysconfig') }
      it 'should contain File[snmpd.sysconfig] with contents "TRAPDOPTS=\'bleh\'"' do
        verify_contents(subject, 'snmpd.sysconfig', [
          'TRAPDOPTS=\'bleh\'',
        ])
      end
    end
  end

  context 'on a supported osfamily (Suse), custom parameters' do
    let :facts do {
      :osfamily               => 'Suse',
      :operatingsystem        => 'Suse',
      :operatingsystemrelease => '11.1'
    }
    end

    describe 'service_ensure => stopped' do
      let(:params) {{ :service_ensure => 'stopped' }}
      it { should contain_service('snmpd').with_ensure('stopped') }
      it { should contain_service('snmptrapd').with_ensure('stopped') }
    end

    describe 'trap_service_ensure => running' do
      let(:params) {{ :trap_service_ensure => 'running' }}
      it { should contain_service('snmpd').with_ensure('running') }
      it { should contain_service('snmptrapd').with_ensure('running') }
    end

    describe 'service_ensure => stopped and trap_service_ensure => running' do
      let :params do {
        :service_ensure      => 'stopped',
        :trap_service_ensure => 'running'
      }
      end
      it { should contain_service('snmpd').with_ensure('stopped') }
      it { should contain_service('snmptrapd').with_ensure('running') }
    end

    describe 'snmpd_options => blah' do
      let(:params) {{ :snmpd_options => 'blah' }}
      it { should contain_file('snmpd.sysconfig') }
      it 'should contain File[snmpd.sysconfig] with contents "SNMPD_LOGLEVEL="blah""' do
        verify_contents(subject, 'snmpd.sysconfig', [
          'SNMPD_LOGLEVEL="blah"',
        ])
      end
    end
  end

end
