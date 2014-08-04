#!/usr/bin/env rspec
require 'spec_helper'

describe 'fluentd', :type => :class do
  context "On a Debian OS " do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystemrelease => '7',
        :concat_basedir         => '/tmp',
        :lsbdistid              => 'Debian',
      }
    end
    context "Debian with repo installed" do
      let (:params) {{
        :package_name => 'td-agent', 
        :package_ensure => 'installed',
        :install_repo => true,
        :service_enable => true,
        :service_ensure => 'running'
      }}
      it "has fluentd::packages" do
        should contain_class('fluentd::packages')
      end
      it "has fluentd::config class" do 
        should contain_class('fluentd::config')
      end
      it "has fluentd::service class" do
        should contain_class('fluentd::service')
      end
      it "the apt repo file exists" do
        should contain_apt__source("treasure-data").with(
          'location'  => 'http://packages.treasuredata.com/debian'
        )
      end
      it "/etc/td-agent/td-agent.conf should be in place" do
        should contain_file("/etc/td-agent/td-agent.conf").with(
          'ensure'  => 'file',
          'owner'   => 'root',
          'group'   => 'root',
          'notify'  => 'Class[Fluentd::Service]'
        ).with_content(/^# Include.*config.d.*/m)
      end
      it "/etc/td-agent/config.d is created" do
        should contain_file("/etc/td-agent/config.d").with(
          'ensure'  => 'directory',
          'owner'   => 'td-agent',
          'group'   => 'td-agent',
          'mode'    => '0750'
        )
      end
      it "td-agent package should be installed" do
        should contain_package("td-agent").with(
          'ensure'  => 'installed'
        )
      end
      it "td-agent is running" do
        should contain_service("td-agent").with(
          'ensure'     => 'running',
          'enable'     => 'true',
          'hasstatus'  => 'true'
        )
      end
    end
    context "Debian without repo installed" do
      let (:params) {{
        :package_name => 'td-agent', 
        :package_ensure => 'installed',
        :install_repo => false,
        :service_enable => true,
        :service_ensure => 'running'
      }}
      it "has fluentd::packages" do
        should contain_class('fluentd::packages')
      end
      it "has fluentd::config class" do 
        should contain_class('fluentd::config')
      end
      it "has fluentd::service class" do
        should contain_class('fluentd::service')
      end
      it "the apt repo file DOES NOT exists" do
        should_not contain_apt__source("treasure-data").with(
          'location'  => 'http://packages.treasure-data.com/debian'
        )
      end
      it "/etc/td-agent/td-agent.conf should be in place" do
        should contain_file("/etc/td-agent/td-agent.conf").with(
          'ensure'  => 'file',
          'owner'   => 'root',
          'group'   => 'root',
          'notify'  => 'Class[Fluentd::Service]'
        ).with_content(/^# Include.*config.d.*/m)
      end
      it "/etc/td-agent/config.d is created" do
        should contain_file("/etc/td-agent/config.d").with(
          'ensure'  => 'directory',
          'owner'   => 'td-agent',
          'group'   => 'td-agent',
          'mode'    => '0750'
        )
      end
      it "td-agent package should be installed" do
        should contain_package("td-agent").with(
          'ensure'  => 'installed'
        )
      end
      it "td-agent is running" do
        should contain_service("td-agent").with(
          'ensure'     => 'running',
          'enable'     => 'true',
          'hasstatus'  => 'true'
        )
      end
    end
  end
  context "On a Redhat-like OS with repo installed" do
    let (:params) {{
      :package_name => 'td-agent', 
      :package_ensure => 'installed',
      :install_repo => true,
      :service_enable => true,
      :service_ensure => 'running'
    }}
    let :facts do
      {
        :osfamily               => 'RedHat',
        :operatingsystemrelease => '6.5',
        :concat_basedir         => '/tmp',
        :lsbdistid              => 'CentOs',
      }
    end

    it "has fluentd::packages" do
      should contain_class('fluentd::packages')
    end
    it "has fluentd::config class" do 
      should contain_class('fluentd::config')
    end
    it "has fluentd::service class" do
      should contain_class('fluentd::service')
    end
    it "the yum repo file exists" do
      should contain_yumrepo('treasuredata')
    end
    it "/etc/td-agent/td-agent.conf should be in place" do
      should contain_file("/etc/td-agent/td-agent.conf").with(
        'ensure'  => 'file',
        'owner'   => 'root',
        'group'   => 'root',
        'notify'  => 'Class[Fluentd::Service]'
      ).with_content(/^# Include.*config.d.*/m)
    end
    it "/etc/td-agent/config.d is created" do
      should contain_file("/etc/td-agent/config.d").with(
        'ensure'  => 'directory',
        'owner'   => 'td-agent',
        'group'   => 'td-agent',
        'mode'    => '0750'
      )
    end
    it "td-agent package should be installed" do
      should contain_package("td-agent").with(
        'ensure'  => 'installed'
      )
    end
    it "td-agent is running" do
      should contain_service("td-agent").with(
        'ensure'     => 'running',
        'enable'     => 'true',
        'hasstatus'  => 'true'
      )
    end
  end
  context "On a Redhat-like OS without repo installed" do
    let (:params) {{
      :package_name => 'td-agent', 
      :package_ensure => 'installed',
      :install_repo => false,
      :service_enable => true,
      :service_ensure => 'running'
    }}
    let :facts do
      {
        :osfamily               => 'RedHat',
        :operatingsystemrelease => '6.5',
        :concat_basedir         => '/tmp',
        :lsbdistid              => 'CentOs',
      }
    end

    it "has fluentd::packages" do
      should contain_class('fluentd::packages')
    end
    it "has fluentd::config class" do 
      should contain_class('fluentd::config')
    end
    it "has fluentd::service class" do
      should contain_class('fluentd::service')
    end
    it "the yum repo file DOES NOT exists" do
      should_not contain_file('/etc/yum.repos.d/td.repo').with_content(/^name=TreasureData$/)
    end
    it "/etc/td-agent/td-agent.conf should be in place" do
      should contain_file("/etc/td-agent/td-agent.conf").with(
        'ensure'  => 'file',
        'owner'   => 'root',
        'group'   => 'root',
        'notify'  => 'Class[Fluentd::Service]'
      ).with_content(/^# Include.*config.d.*/m)
    end
    it "/etc/td-agent/config.d is created" do
      should contain_file("/etc/td-agent/config.d").with(
        'ensure'  => 'directory',
        'owner'   => 'td-agent',
        'group'   => 'td-agent',
        'mode'    => '0750'
      )
    end
    it "td-agent package should be installed" do
      should contain_package("td-agent").with(
        'ensure'  => 'installed'
      )
    end
    it "td-agent is running" do
      should contain_service("td-agent").with(
        'ensure'     => 'running',
        'enable'     => 'true',
        'hasstatus'  => 'true'
      )
    end
  end
end
