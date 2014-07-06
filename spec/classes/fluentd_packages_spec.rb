#!/usr/bin/env rspec
require 'spec_helper'

describe 'fluentd::packages', :type => :class do
  let (:params) {{:package_name => 'td-agent', :package_ensure => 'installed'}}
  context "On a Debian OS" do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystemrelease => '7',
        :lsbdistid              => 'Debian',
      }
    end

    context "with install_repo=>true" do
      let(:params) { {:install_repo => true} }
      it do
        should contain_apt__source("treasure-data").with(
          'location'  => 'http://packages.treasuredata.com/debian'
        )
      end
    end
    it { should contain_package("libxslt1.1").with(
      'ensure'  => 'installed'
      )
    }
    it { should contain_package("libyaml-0-2").with(
      'ensure'  => 'installed'
      )
    }
    it { should contain_package("td-agent").with(
      'ensure'  => 'installed'
      )
    }
  end

  context "On a RedHat/Centos OS" do

    let :params  do
      {
        :package_name => 'td-agent',
        :package_ensure => 'running',
      } 
    end

    let :facts do
      {
        :osfamily               => 'Redhat',
      }
    end

    it { should contain_class('fluentd::packages')}
    
    context "with install_repo=>true" do
      let(:params) { {:install_repo => true} }
      it do
        should contain_yumrepo('treasuredata').with(
          'baseurl'  => 'http://packages.treasuredata.com/redhat/$basearch',
          'gpgkey'   => 'http://packages.treasuredata.com/redhat/RPM-GPG-KEY-td-agent',
          'gpgcheck' => 1
        )
      end
    end

    it { should contain_package("td-agent").with(
      'ensure'  => 'running'
      )
    }
  end
end
