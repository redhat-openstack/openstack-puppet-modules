require 'spec_helper'

describe 'zookeeper::repo', :type => :class do
  shared_examples 'redhat-install' do |os, codename, puppet|
    let(:hardwaremodel){ 'x86_64' }

    let(:facts) {{
      :operatingsystem => os,
      :osfamily => 'RedHat',
      :lsbdistcodename => codename,
      :operatingsystemmajrelease => codename,
      :hardwaremodel => hardwaremodel,
      :puppetversion => puppet,
    }}
  end

  context 'on RedHat-like system' do
    let(:user) { 'zookeeper' }
    let(:group) { 'zookeeper' }

    let(:params) {{
      :source => 'cloudera',
      :cdhver => '5'
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
      :cdhver => '5',
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
      :cdhver => '5',
    } }

    it { expect {
        should compile
    }.to raise_error(/is not supported for redhat version/) }
  end

  context 'fail when CDH version not supported' do
    let(:facts) {{
      :osfamily => 'RedHat',
      :operatingsystemmajrelease => '7',
      :hardwaremodel => 'x86_64',
      :osrel => '7',
    }}

    let(:params) { {
      :source => 'cloudera',
      :cdhver => '6',
    } }

    it { expect {
        should compile
    }.to raise_error(/is not a supported cloudera repo./) }
  end

  context 'fail when repository source not supported' do
    let(:facts) {{
      :osfamily => 'RedHat',
      :operatingsystemmajrelease => '7',
      :hardwaremodel => 'x86_64',
      :osrel => '7',
    }}

    let(:params) { {
      :source => 'another-repo',
    } }

    it { expect {
        should compile
    }.to raise_error(/provides no repository information for yum repository/) }
  end
end
