require 'spec_helper'

describe 'zookeeper::repo', :type => :class do
  shared_examples 'redhat-install' do |os, codename, puppet|
    let(:cdhver){ 4 }
    let(:hardwaremodel){ 'x86_64' }

    let(:facts) {{
      :operatingsystem => os,
      :osfamily => 'RedHat',
      :lsbdistcodename => codename,
      :operatingsystemmajrelease => codename,
      :hardwaremodel => hardwaremodel,
      :puppetversion => puppet,
    }}

    it {
      should contain_yumrepo("cloudera-cdh#{cdhver}").with({
          'gpgkey' => "http://archive.cloudera.com/cdh#{cdhver}/redhat/#{codename}/#{hardwaremodel}/cdh/RPM-GPG-KEY-cloudera"
        })
    }
  end

  context 'on RedHat-like system' do
    let(:user) { 'zookeeper' }
    let(:group) { 'zookeeper' }

    let(:params) {{
      :source => 'cloudera',
    }}
    # ENV variable might contain characters which are not supported
    # by versioncmp function (like '~>')
    puppet = `puppet --version`

    it_behaves_like 'redhat-install', 'RedHat', '6', puppet
  end

  context 'fail when architecture not supported' do
    let(:facts) {{
      :osfamily => 'RedHat',
      :operatingsystemmajrelease => '7',
      :hardwaremodel => 'arc',
    }}

    let(:params) { {
      :source => 'cloudera',
    } }

    it { expect {
        should compile
    }.to raise_error(/is not supported for architecture/) }
  end

  context 'fail when release not supported' do
    let(:facts) {{
      :osfamily => 'RedHat',
      :operatingsystemmajrelease => '8',
      :hardwaremodel => 'x86_64',
      :osrel => '8',
    }}

    let(:params) { {
      :source => 'cloudera',
    } }

    it { expect {
        should compile
    }.to raise_error(/is not supported for redhat version/) }
  end
end