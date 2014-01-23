require 'spec_helper'

describe 'fluentd::packages', :type => :class do
  context "On a Debian OS" do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystemrelease => '7',
        :concat_basedir         => '/tmp',
      }
    end

    it { should contain_apt__source("treasure-data").with(
      'location'  => 'http://packages.treasure-data.com/debian',
      )
    }
    it { should contain_package("libxslt1.1").with(
      'ensure'  => 'present',
      )
    }
    it { should contain_package("libyaml-0-2").with(
      'ensure'  => 'present',
      )
    }
    it { should contain_package("td-agent").with(
      'ensure'  => 'present',
      )
    }
  end
end

