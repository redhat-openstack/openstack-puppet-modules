require 'spec_helper'

describe 'fluentd::packages', :type => :class do
  context "On a Debian OS" do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystemrelease => '7',
        :lsbdistid              => 'Debian',
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


  context "On a RedHat/Centos OS" do
    let :facts do
      {
        :osfamily               => 'Redhat',
        :operatingsystemrelease => '6',
        :lsbdistid              => 'Redhat',
      }
    end

    it { should contain_yumrepo("treasuredata").with(
      'baseurl'  => 'http://packages.treasure-data.com/redhat/$basearch',
      'gpgkey'   => 'http://packages.treasure-data.com/redhat/RPM-GPG-KEY-td-agent',
      'gpgcheck' => '1',
      )
    }
    it { should contain_package("td-agent").with(
      'ensure'  => 'present',
      )
    }
    it { should contain_user("td-agent").with(
      'ensure'  => 'present',
      'groups'  => 'adm',
      )
    }
  end
end

