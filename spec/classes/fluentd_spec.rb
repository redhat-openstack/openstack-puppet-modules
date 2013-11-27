require 'spec_helper'

describe 'fluentd', :type => :class do
  context "On a Debian OS" do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystemrelease => '7',
        :concat_basedir         => '/tmp',
      }
    end

    it do
      should include_class('fluentd::packages')
    end


    it { should contain_file("/etc/td-agent/td-agent.conf").with(
      'ensure'  => 'file',
      'owner'   => 'root',
      'group'   => 'root',
      'source'  => 'puppet:///modules/fluentd/etc/fluentd/td-agent.conf',
      'require' => 'Package[td-agent]'
      )
    }
    it { should contain_file("/etc/td-agent/config.d").with(
      'ensure'  => 'directory',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '750',
      'require' => 'Package[td-agent]'
      )
    }
  end
end

