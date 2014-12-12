#
# Copyright (C) 2014 eNovance SAS <licensing@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# Unit tests for cloud
#

require 'spec_helper'

describe 'cloud' do

  let :params do
    { }
  end

  shared_examples_for 'cloud node' do

    let :pre_condition do
      '
        include concat::setup
      '
    end

    let :file_defaults do
      {
        :mode    => '0644'
      }
    end

    it {is_expected.to contain_class('ntp')}

    it {is_expected.to contain_file('/etc/motd').with(
      {:ensure => 'file'}.merge(file_defaults)
    )}

    it { is_expected.to contain_service('cron').with({
      :name   => platform_params[:cron_service_name],
      :ensure => 'running',
      :enable => true
    }) }

    context 'with firewall enabled' do
      before :each do
        params.merge!(
          :manage_firewall => true,
        )
      end

      it 'configure basic pre firewall rules' do
        is_expected.to contain_firewall('000 accept related established rules').with(
          :proto  => 'all',
          :state  => ['RELATED', 'ESTABLISHED'],
          :action => 'accept',
        )
        is_expected.to contain_firewall('001 accept all icmp').with(
          :proto  => 'icmp',
          :action => 'accept',
          :state  => ['NEW'],
        )
        is_expected.to contain_firewall('002 accept all to lo interface').with(
          :proto   => 'all',
          :iniface => 'lo',
          :action  => 'accept',
          :state   => ['NEW'],
        )
        is_expected.to contain_firewall('003 accept ssh').with(
          :port   => '22',
          :proto  => 'tcp',
          :action => 'accept',
          :state  => ['NEW'],
        )
      end

      it 'configure basic post firewall rules' do
        is_expected.to contain_firewall('999 drop all').with(
          :proto  => 'all',
          :action => 'drop',
          :source => '0.0.0.0/0',
        )
      end
    end

    context 'with custom firewall rules' do
      before :each do
        params.merge!(
          :manage_firewall     => true,
          :firewall_rules => {
            '300 add custom application 1' => {'port' => '999', 'proto' => 'udp', 'action' => 'accept'},
            '301 add custom application 2' => {'port' => '8081', 'proto' => 'tcp', 'action' => 'accept'}
          }
        )
      end
      it 'configure custom firewall rules' do
        is_expected.to contain_firewall('300 add custom application 1').with(
          :port   => '999',
          :proto  => 'udp',
          :action => 'accept',
          :state  => ['NEW'],
        )
        is_expected.to contain_firewall('301 add custom application 2').with(
          :port   => '8081',
          :proto  => 'tcp',
          :action => 'accept',
          :state  => ['NEW'],
        )
      end
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    let :platform_params do
      { :cron_service_name => 'cron'}
    end

    it_configures 'cloud node'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily       => 'RedHat',
        :hostname       => 'redhat1' }
    end

    let :platform_params do
      { :cron_service_name => 'crond'}
    end

    let :params do
      { :rhn_registration => { "username" => "rhn", "password" => "pass" } }
    end

    it_configures 'cloud node'

    xit { is_expected.to contain_rhn_register('rhn-redhat1') }

    context 'with SELinux set to enforcing' do
      let :params do
        { :selinux_mode      => 'enforcing',
          :selinux_modules   => ['module1', 'module2'],
          :selinux_booleans  => ['foo', 'bar'],
          :selinux_directory => '/path/to/modules'}
      end

      it 'set SELINUX=enforcing' do
        is_expected.to contain_class('cloud::selinux').with(
          :mode      => params[:selinux_mode],
          :booleans  => params[:selinux_booleans],
          :modules   => params[:selinux_modules],
          :directory => params[:selinux_directory],
          :stage     => 'setup',
        )
      end
    end

  end

  context 'on other platforms' do
    let :facts do
      { :osfamily => 'Solaris' }
    end

    it { is_expected.to compile.and_raise_error(/module puppet-openstack-cloud only support/) }

  end
end
