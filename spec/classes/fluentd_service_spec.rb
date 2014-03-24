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

    it { should contain_service("td-agent").with(
      'ensure'     => 'running',
      'enable'     => 'true',
      'hasstatus'  => 'true',
      )
    }
  end
end

