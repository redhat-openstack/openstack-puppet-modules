#!/usr/bin/env rspec
require 'spec_helper'

describe 'fluentd::config', :type => :class do
  context "On a Debian OS, config files should be written" do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystemrelease => '7',
        :concat_basedir         => '/tmp',
        :lsbdistid              => 'Debian',
      }
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
  end
  context "On a Redhat OS, config files should be written" do
    let :facts do
      {
        :osfamily               => 'RedHat',
        :operatingsystemrelease => '6.5',
        :concat_basedir         => '/tmp',
        :lsbdistid              => 'CentOS',
      }
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
  end
end
