#!/usr/bin/env rspec
require 'spec_helper'

describe 'fluentd::service', :type => :class do
  context "On a Debian OS" do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystemrelease => '7',
        :concat_basedir         => '/tmp',
        :lsbdistid              => 'Debian',
      }
    end
    context "td-agent running and enabled" do
      let (:params) {{:service_ensure => 'running', :service_enable => true}}
      it { should contain_service("td-agent").with(
        'ensure'     => 'running',
        'enable'     => 'true',
        'hasstatus'  => 'true'
        )
      }
    end
    context "td-agent stopped but enabled" do
      let (:params) {{:service_ensure => 'stopped', :service_enable => true}}
      it { should contain_service("td-agent").with(
        'ensure'     => 'stopped',
        'enable'     => 'true',
        'hasstatus'  => 'true'
        )
      }
    end
    context "td-agent stopped and disabled" do
      let (:params) {{:service_ensure => 'stopped', :service_enable => false}}
      it { should contain_service("td-agent").with(
        'ensure'     => 'stopped',
        'enable'     => 'false',
        'hasstatus'  => 'true'
        )
      }
    end
  end
  context "On a Redhat OS" do
    let :facts do
      {
        :osfamily               => 'RedHat',
        :operatingsystemrelease => '6.5',
        :concat_basedir         => '/tmp',
        :lsbdistid              => 'CentOs',
      }
    end
    context "td-agent running and enabled" do
      let (:params) {{:service_ensure => 'running', :service_enable => true}}
      it { should contain_service("td-agent").with(
        'ensure'     => 'running',
        'enable'     => 'true',
        'hasstatus'  => 'true'
        )
      }
    end
    context "td-agent stopped but enabled" do
      let (:params) {{:service_ensure => 'stopped', :service_enable => true}}
      it { should contain_service("td-agent").with(
        'ensure'     => 'stopped',
        'enable'     => 'true',
        'hasstatus'  => 'true'
        )
      }
    end
    context "td-agent stopped and disabled" do
      let (:params) {{:service_ensure => 'stopped', :service_enable => false}}
      it { should contain_service("td-agent").with(
        'ensure'     => 'stopped',
        'enable'     => 'false',
        'hasstatus'  => 'true'
        )
      }
    end
  end
end
