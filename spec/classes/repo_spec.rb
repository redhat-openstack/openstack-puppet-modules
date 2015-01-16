require 'spec_helper'

describe 'zookeeper::repo', :type => :class do
  shared_examples 'redhat-install' do |os, codename|
    let(:cdhver){ 4 }
    let(:hardwaremodel){ 'x86_64' }

    let(:facts) {{
      :operatingsystem => os,
      :osfamily => 'RedHat',
      :lsbdistcodename => codename,
      :operatingsystemmajrelease => codename,
      :hardwaremodel => hardwaremodel,
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

    let(:params) { {
      :source => 'cloudera',
    } }

    it_behaves_like 'redhat-install', 'RedHat', '6'
  end
end