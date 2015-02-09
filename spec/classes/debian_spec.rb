require 'spec_helper'

describe 'zookeeper::os::debian', :type => :class do
  shared_examples 'debian-install' do |os, codename|
    let(:facts) {{
      :operatingsystem => os,
      :osfamily => 'Debian',
      :lsbdistcodename => codename,
    }}

    it { should contain_package('zookeeper') }
    it { should contain_package('zookeeperd') }
    it { should contain_package('cron') }

    it 'installs cron script' do
      should contain_cron('zookeeper-cleanup').with({
        'ensure'    => 'present',
        'command'   => '/usr/lib/zookeeper/bin/zkCleanup.sh /var/lib/zookeeper 1',
        'user'      => 'zookeeper',
        'hour'      => '2',
        'minute'      => '42',
      })
    end

    context 'without cron' do
      let(:user) { 'zookeeper' }
      let(:group) { 'zookeeper' }

      let(:params) { {
        :snap_retain_count => 0,
      } }

      it { should contain_package('zookeeper') }
      it { should contain_package('zookeeperd') }
      it { should_not contain_package('cron') }
    end

    context 'allow changing service package name' do
      let(:user) { 'zookeeper' }
      let(:group) { 'zookeeper' }

      let(:params) { {
        :service_package => 'zookeeper-server',
      } }

      it { should contain_package('zookeeper') }
      it { should contain_package('zookeeper-server') }
      it { should_not contain_package('zookeeperd') }
    end

    context 'allow installing multiple packages' do
      let(:user) { 'zookeeper' }
      let(:group) { 'zookeeper' }

      let(:params) { {
        :packages => [ 'zookeeper', 'zookeeper-bin' ],
      } }

      it { should contain_package('zookeeper') }
      it { should contain_package('zookeeper-bin') }
    end

    context 'removing package' do
      let(:user) { 'zookeeper' }
      let(:group) { 'zookeeper' }

      let(:params) { {
        :ensure => 'absent',
      } }

      it {

        should contain_package('zookeeper').with({
        'ensure'  => 'absent',
        })
      }
      it {
        should contain_package('zookeeperd').with({
        'ensure'  => 'absent',
        })
      }
      it { should_not contain_package('cron') }
    end
  end

  context 'on debian-like system' do
    let(:user) { 'zookeeper' }
    let(:group) { 'zookeeper' }

    let(:params) { {
      :snap_retain_count => 1,
    } }

    it_behaves_like 'debian-install', 'Debian', 'squeeze'
    it_behaves_like 'debian-install', 'Debian', 'wheezy'
    it_behaves_like 'debian-install', 'Ubuntu', 'precise'
  end

  context 'does not install cron script on trusty' do
    let(:facts) {{
      :operatingsystem => 'Ubuntu',
      :osfamily => 'Debian',
      :lsbdistcodename => 'trusty',
    }}

    it { should_not contain_package('cron') }

    it 'installs cron script' do
      should_not contain_cron('zookeeper-cleanup').with({
        'ensure'    => 'present',
        'command'   => '/usr/lib/zookeeper/bin/zkCleanup.sh /var/lib/zookeeper 1',
        'user'      => 'zookeeper',
        'hour'      => '2',
        'minute'      => '42',
      })
    end
  end

  context 'with java installation' do
    let(:facts) {{
      :operatingsystem => 'Ubuntu',
      :osfamily => 'Debian',
      :lsbdistcodename => 'trusty',
    }}

    let(:params) { {
      :install_java => true,
      :java_package => 'openjdk-7-jre-headless',
    } }

    it { should contain_package('openjdk-7-jre-headless').with({
      'ensure'  => 'present',
      }) }
    it { should contain_package('zookeeper').with({
      'ensure'  => 'present',
      }) }
  end

  context 'fail when no packge provided' do
    let(:facts) {{
      :operatingsystem => 'Ubuntu',
      :osfamily => 'Debian',
      :lsbdistcodename => 'trusty',
    }}

    let(:params) { {
      :install_java => true,
    } }

    it { expect {
        should compile
    }.to raise_error(/Java installation is required/) }
  end

end
